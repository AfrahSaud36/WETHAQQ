import SwiftUI

struct CloudKitUser: View {
    
    @StateObject private var vm = CloudKitUserViewModel()
    
    var body: some View {
        VStack {
            Text("IS SIGNED IN:\(vm.isSignedInToiCloud)")
            Text(vm.error)
            
            Text("Permission: \(vm.permissionStatus.description.uppercased())")
            Text("NAME: \(vm.userName)")
        }
    }
}





struct CloudKitUserBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        CloudKitUser()
    }
}


