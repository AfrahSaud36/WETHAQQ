import Foundation
import CloudKit

@MainActor
class AllServicesViewModel: ObservableObject {
    @Published var services: [Service] = []
    @Published var searchText: String = ""
    
    private let bookmarkManager = BookmarkManager.shared
    
    func fetchAllServices() {
        let publicDatabase = CKContainer.default().publicCloudDatabase
        let query = CKQuery(recordType: "post", predicate: NSPredicate(value: true))
        
        Task {
            do {
                let (records, _) = try await publicDatabase.records(matching: query)
                let fetchedServices = records.compactMap { _, result -> Service? in
                    guard case .success(let record) = result,
                          let title = record["title"] as? String,
                          let price = record["price"] as? Double,
                          let description = record["description"] as? String,
                          let userRef = record["user"] as? CKRecord.Reference else {
                        return nil
                    }
                    
                    return Service(
                        id: UUID(),
                        title: title,
                        description: description,
                        price: price,
                        imageName: record["images"] as? String ?? "defaultImage",
                        user: "Loading...",
                        userReference: userRef,
                        imageAssets: record["images"] as? [CKAsset]
                    )
                }
                
                await MainActor.run {
                    self.services = fetchedServices
                }
            } catch {
                print("Error fetching data: \(error)")
            }
        }
    }
    
    var filteredServices: [Service] {
        if searchText.isEmpty {
            return services
        } else {
            return services.filter { service in
                service.title.lowercased().contains(searchText.lowercased()) ||
                service.user.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    func toggleBookmark(service: Service) async {
        await bookmarkManager.toggleBookmark(service: service)
    }
    
    func isBookmarked(service: Service) async -> Bool {
        await bookmarkManager.isBookmarked(service: service)
    }
    
    func getBookmarkedServices() async -> [Service] {
        await Array(bookmarkManager.bookmarkedServices)
    }
}
