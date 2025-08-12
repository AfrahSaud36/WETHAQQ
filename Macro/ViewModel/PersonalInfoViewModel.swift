

import CloudKit
import SwiftUI

@MainActor
class PersonalInfoViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var bio: String = ""
    @Published var isLoading: Bool = true
    @Published var isSaved: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var phoneNumber: String = ""

    

    private var existingRecord: CKRecord?
    private var userRecordID: CKRecord.ID?
    
    
    
    
    //for image 1
    @Published var profileImage: UIImage?
    
    
    

    init() {
        Task {
            await fetchiCloudUserID()
        }
    }
    
    //for image 2
    private func saveImageToTemporaryLocation(_ image: UIImage) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("❌ Failed to save image to temp location: \(error)")
            return nil
        }
    }
    
    func fetchiCloudUserID() async {
        do {
            let status = try await CKContainer.default().accountStatus()
            guard status == .available else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }

            let id = try await CKContainer.default().userRecordID()
            self.userRecordID = id
            
           await fetchProfile()
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    
    }
    
    
    
    
    
    
    
    
    
    
    func fetchProfile() async {
        guard let userRecordID = userRecordID else { return }

        let reference = CKRecord.Reference(recordID: userRecordID, action: .none)
        let predicate = NSPredicate(format: "owner == %@", reference)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)

        do {
            let (results, _) = try await CKContainer.default().publicCloudDatabase.records(matching: query)

            for (_, result) in results {
                switch result {
                case .success(let record):
                    self.name = record["name"] as? String ?? ""
                    self.email = record["email"] as? String ?? ""
                    self.bio = record["bio"] as? String ?? ""
                    self.phoneNumber = record["phoneNumber"] as? String ?? ""

                    if let asset = record["profileImage"] as? CKAsset,
                       let fileURL = asset.fileURL,
                       let imageData = try? Data(contentsOf: fileURL),
                       let image = UIImage(data: imageData) {
                        self.profileImage = image
                    }

                    self.existingRecord = record
                case .failure(let error):
                    print("❌ Error loading record: \(error.localizedDescription)")
                }
            }
        } catch {
            print("❌ Query error: \(error.localizedDescription)")
        }

        self.isLoading = false
    }

    
    
    
    
    
    func saveProfile() async {
        guard let userRecordID = userRecordID else {
            self.errorMessage = "لم يتم التعرف على المستخدم"
            self.showError = true
            return
        }

        let record: CKRecord
        if let existing = existingRecord {
            record = existing
        } else {
            record = CKRecord(recordType: "UserProfile")
            record["owner"] = CKRecord.Reference(recordID: userRecordID, action: .deleteSelf)
        }

        record["name"] = name as CKRecordValue
        record["email"] = email as CKRecordValue
        record["bio"] = bio as CKRecordValue
        record["userID"] = userRecordID.recordName as CKRecordValue
        record["phoneNumber"] = phoneNumber as CKRecordValue

        if let image = profileImage,
           let imageURL = saveImageToTemporaryLocation(image) {
            record["profileImage"] = CKAsset(fileURL: imageURL)
        }

        do {
            let saved = try await CKContainer.default().publicCloudDatabase.save(record)
            self.existingRecord = saved
            self.isSaved = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.isSaved = false
            }
        } catch {
            self.errorMessage = "فشل في الحفظ: \(error.localizedDescription)"
            self.showError = true
        }
    }

//    func saveProfile() async {
//        guard let userRecordID = userRecordID else {
//            self.errorMessage = "لم يتم التعرف على المستخدم"
//            self.showError = true
//            return
//        }
//
//        let record: CKRecord
//        if let existing = existingRecord {
//            record = existing
//        } else {
//            record = CKRecord(recordType: "UserProfile")
//            record["owner"] = CKRecord.Reference(recordID: userRecordID, action: .deleteSelf)
//        }
//
//        record["name"] = name as CKRecordValue
//        record["email"] = email as CKRecordValue
//        record["bio"] = bio as CKRecordValue
//
//        do {
//            let saved = try await CKContainer.default().publicCloudDatabase.save(record)
//            self.existingRecord = saved
//            self.isSaved = true
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                self.isSaved = false
//            }
//        } catch {
//            self.errorMessage = "فشل في الحفظ: \(error.localizedDescription)"
//            self.showError = true
//        }
//    }

    func checkiCloudStatus() async -> Bool {
        do {
            let status = try await CKContainer.default().accountStatus()
            return status == .available
        } catch {
            return false
        }
    }
}

