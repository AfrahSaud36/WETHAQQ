import SwiftUI
import CloudKit

class CloudKitUserViewModel: ObservableObject {
    
    @Published var permissionStatus: Bool = false
    @Published var isSignedInToiCloud: Bool = false
    @Published var error: String = ""
    @Published var userName: String = ""
    
    init() {
        getiCloudStatus()
    }
    
    private func getiCloudStatus() {
        
        CKContainer.default().accountStatus { [weak self] status, _ in // Renamed the second 'retunedStatus' to '_'
            DispatchQueue.main.async {
                switch status {  // Used 'status' instead of 'retunedStatus'
                case .available:
                    self?.isSignedInToiCloud = true
                    
                case .noAccount:
                    self?.error = CloudKitError.iCloudAccountNotFound.rawValue

                case .couldNotDetermine:
                    self?.error = CloudKitError.iCloudAccountNotDataremined.rawValue

                case .restricted:
                    self?.error = CloudKitError.iCloudAccountRwstricted.rawValue

                default:
                    self?.error = CloudKitError.iCloudAccountUnkown.rawValue
                }
            }
        }
    }
    
    enum CloudKitError: String, LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDataremined
        case iCloudAccountRwstricted
        case iCloudAccountUnkown
    }
}
