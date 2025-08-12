import Foundation
import CloudKit

class ServicesViewModel: ObservableObject {
    @Published var services: [CKRecord] = []
    
    func fetchServices() {
        let publicDatabase = CKContainer.default().publicCloudDatabase
        let query = CKQuery(recordType: "post", predicate: NSPredicate(value: true))
        
        publicDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("حدث خطأ أثناء جلب البيانات: \(error)")
            } else {
                DispatchQueue.main.async {
                    self.services = records ?? []
                }
            }
        }
    }
    
    func filterServicesByCategory(_ category: String) -> [CKRecord] {
        return services.filter { service in
            guard let tos = service["TOS"] as? CKRecord.Reference else { return false }
            return tos.recordID.recordName == category
        }
    }
    
    // دالة لجلب اسم المستخدم باستخدام userID
    func getUserNameFromUserProfile(userID: String, completion: @escaping (String) -> Void) {
        let publicDatabase = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(format: "userID == %@", userID)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("حدث خطأ أثناء جلب بيانات المستخدم: \(error)")
                completion("Unknown User")
            } else {
                if let record = records?.first,
                   let userName = record["name"] as? String {
                    completion(userName)
                } else {
                    completion("Unknown User")
                }
            }
        }
    }
    
    // دالة للحصول على بيانات الخدمة بشكل مفصل
    func getServiceDetails(_ service: CKRecord) -> String {
        let title = service["title"] as? String ?? "No Title"
        let description = service["description"] as? String ?? "No Description"
        let price = service["price"] as? Double ?? 0.0
        let user = service["user"] as? String ?? "Unknown User"
        
        return "Title: \(title)\nDescription: \(description)\nPrice: \(price) SR\nUser: \(user)"
    }
    
    // دالة لإحضار الصور المرتبطة بالخدمة
    func getServiceImage(_ service: CKRecord) -> String {
        return service["images"] as? String ?? "defaultImage"
    }
}
