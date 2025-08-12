import Foundation
import CloudKit

struct Service: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let description: String
    let price: Double
    let imageName: String
    var user: String
    var userReference: CKRecord.Reference?
    var imageAssets: [CKAsset]?
    
    // Custom Equatable implementation to compare services
    static func == (lhs: Service, rhs: Service) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Custom hash function for Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Custom CodingKeys to exclude CKRecord.Reference and CKAsset from Codable
    enum CodingKeys: String, CodingKey {
        case id, title, description, price, imageName, user
    }
    
    
    
    init(id: UUID, title: String, description: String, price: Double, imageName: String, user: String, userReference: CKRecord.Reference? = nil, imageAssets: [CKAsset]? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.imageName = imageName
        self.user = user
        self.userReference = userReference
        self.imageAssets = imageAssets
    }
}
