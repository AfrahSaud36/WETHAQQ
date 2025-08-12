import Foundation
import CloudKit
import SwiftUI

@MainActor
class BookmarkManager: ObservableObject {
    @Published var bookmarkedServices: Set<Service> = []
    private let userDefaults = UserDefaults.standard
    private let bookmarksKey = "bookmarkedServices"
    
    static let shared = BookmarkManager() // Singleton instance
    private var userRecordID: CKRecord.ID?
    private var isCloudKitAvailable = false
    
    init() {
        loadBookmarks()
        Task {
            await checkCloudKitAvailability()
        }
    }
    
    private func checkCloudKitAvailability() async {
        do {
            let status = try await CKContainer.default().accountStatus()
            isCloudKitAvailable = status == .available
            if isCloudKitAvailable {
                userRecordID = try await CKContainer.default().userRecordID()
                await syncBookmarksWithCloud()
            }
        } catch {
            print("CloudKit error: \(error.localizedDescription)")
            isCloudKitAvailable = false
        }
    }
    
    func toggleBookmark(service: Service) {
        if isBookmarked(service: service) {
            Task {
                do {
                    // First, try to delete from CloudKit
                    try await removeBookmarkFromCloud(service: service)
                    
                    // Only if CloudKit deletion is successful, remove from local storage
                    await MainActor.run {
                        bookmarkedServices.remove(service)
                        saveBookmarks()
                        NotificationCenter.default.post(
                            name: NSNotification.Name("BookmarkUpdated"),
                            object: nil,
                            userInfo: ["bookmarks": Array(bookmarkedServices)]
                        )
                    }
                } catch {
                    print("Failed to remove bookmark: \(error.localizedDescription)")
                    // Don't remove from local storage if CloudKit deletion failed
                }
            }
        } else {
            bookmarkedServices.insert(service)
            Task {
                await saveBookmarkToCloud(service: service)
                saveBookmarks()
                NotificationCenter.default.post(
                    name: NSNotification.Name("BookmarkUpdated"),
                    object: nil,
                    userInfo: ["bookmarks": Array(bookmarkedServices)]
                )
            }
        }
    }
    
    private func saveBookmarkToCloud(service: Service) async {
        guard isCloudKitAvailable, let userRecordID = userRecordID else { return }
        
        do {
            let record = CKRecord(recordType: "Bookmark")
            record["userID"] = userRecordID.recordName
            record["serviceID"] = service.id.uuidString
            record["title"] = service.title
            record["description"] = service.description
            record["price"] = service.price
            record["user"] = service.user
            
            if let imageAssets = service.imageAssets {
                record["images"] = imageAssets
            }
            
            try await CKContainer.default().publicCloudDatabase.save(record)
        } catch {
            print("Error saving bookmark to CloudKit: \(error.localizedDescription)")
        }
    }
    
    private func removeBookmarkFromCloud(service: Service) async throws {
        guard isCloudKitAvailable, let userRecordID = userRecordID else {
            throw BookmarkError.cloudKitUnavailable
        }
        
        let predicate = NSPredicate(format: "userID == %@ AND serviceID == %@", 
                                  userRecordID.recordName, service.id.uuidString)
        let query = CKQuery(recordType: "Bookmark", predicate: predicate)
        
        do {
            let (results, _) = try await CKContainer.default().publicCloudDatabase.records(matching: query)
            
            // If no records found, throw error
            guard !results.isEmpty else {
                throw BookmarkError.recordNotFound
            }
            
            // Delete all matching records (should typically be just one)
            try await withThrowingTaskGroup(of: Void.self) { group in
                for (recordID, result) in results {
                    if case .success = result {
                        group.addTask {
                            try await CKContainer.default().publicCloudDatabase.deleteRecord(withID: recordID)
                        }
                    }
                }
                // Wait for all deletions to complete
                try await group.waitForAll()
            }
        } catch {
            print("Error removing bookmark from CloudKit: \(error.localizedDescription)")
            throw BookmarkError.deletionFailed(error)
        }
    }
    
    private func syncBookmarksWithCloud() async {
        guard isCloudKitAvailable, let userRecordID = userRecordID else { return }
        
        do {
            let predicate = NSPredicate(format: "userID == %@", userRecordID.recordName)
            let query = CKQuery(recordType: "Bookmark", predicate: predicate)
            
            let (results, _) = try await CKContainer.default().publicCloudDatabase.records(matching: query)
            var cloudBookmarks: Set<Service> = []
            
            for (_, result) in results {
                if case .success(let record) = result,
                   let serviceID = record["serviceID"] as? String,
                   let title = record["title"] as? String,
                   let description = record["description"] as? String,
                   let price = record["price"] as? Double {
                    let service = Service(
                        id: UUID(uuidString: serviceID) ?? UUID(),
                        title: title,
                        description: description,
                        price: price,
                        imageName: "",
                        user: record["user"] as? String ?? "",
                        imageAssets: record["images"] as? [CKAsset]
                    )
                    cloudBookmarks.insert(service)
                }
            }
            
            // Merge cloud bookmarks with local bookmarks
            bookmarkedServices = bookmarkedServices.union(cloudBookmarks)
            saveBookmarks() // Update local storage
            
            // Sync local bookmarks to cloud if they don't exist
            for service in bookmarkedServices {
                let exists = cloudBookmarks.contains(service)
                if !exists {
                    await saveBookmarkToCloud(service: service)
                }
            }
        } catch {
            print("Error syncing bookmarks with CloudKit: \(error.localizedDescription)")
        }
    }
    
    func isBookmarked(service: Service) -> Bool {
        bookmarkedServices.contains(service)
    }
    
    private func saveBookmarks() {
        if let encoded = try? JSONEncoder().encode(Array(bookmarkedServices)) {
            userDefaults.set(encoded, forKey: bookmarksKey)
            userDefaults.synchronize() // Ensure immediate save
        }
    }
    
    private func loadBookmarks() {
        if let data = userDefaults.data(forKey: bookmarksKey),
           let decoded = try? JSONDecoder().decode([Service].self, from: data) {
            bookmarkedServices = Set(decoded)
        }
    }
    
    func getAllBookmarks() -> [Service] {
        return Array(bookmarkedServices).sorted { $0.title < $1.title }
    }
    
    func clearBookmarks() {
        Task {
            await clearCloudBookmarks()
        }
        bookmarkedServices.removeAll()
        saveBookmarks()
        NotificationCenter.default.post(name: NSNotification.Name("BookmarkUpdated"), object: nil)
    }
    
    private func clearCloudBookmarks() async {
        guard isCloudKitAvailable, let userRecordID = userRecordID else { return }
        
        do {
            let predicate = NSPredicate(format: "userID == %@", userRecordID.recordName)
            let query = CKQuery(recordType: "Bookmark", predicate: predicate)
            
            let (results, _) = try await CKContainer.default().publicCloudDatabase.records(matching: query)
            for (recordID, result) in results {
                if case .success = result {
                    try await CKContainer.default().publicCloudDatabase.deleteRecord(withID: recordID)
                }
            }
        } catch {
            print("Error clearing cloud bookmarks: \(error.localizedDescription)")
        }
    }
    
    // Error types for bookmark operations
    enum BookmarkError: Error {
        case cloudKitUnavailable
        case recordNotFound
        case deletionFailed(Error)
        
        var localizedDescription: String {
            switch self {
            case .cloudKitUnavailable:
                return "CloudKit is not available"
            case .recordNotFound:
                return "Bookmark record not found"
            case .deletionFailed(let error):
                return "Failed to delete bookmark: \(error.localizedDescription)"
            }
        }
    }
} 
