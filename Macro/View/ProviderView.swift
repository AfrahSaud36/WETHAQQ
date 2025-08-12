import SwiftUI
import CloudKit

struct ProviderView: View {
    let userID: String
    
    @State private var userName: String = ""
    @State private var userBio: String = ""
    @State private var userImage: UIImage?
    @State private var posts: [Service] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var vm = PersonalInfoViewModel()

    var body: some View {
            VStack(alignment: .leading, spacing: 27) {
                // Back Button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.system(size: 24))
                        .padding(.leading)
                }
                    // Profile Section
                    VStack( alignment: .leading ,spacing: 4) {
                        HStack(spacing: 2) {
                            if let image = vm.profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .padding(12)

                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                                    .clipShape(Circle())
                                    .padding(12)
                            }


                            
                            Text(userName)
                                .font(.title2)
                                .fontWeight(.semibold)
                               //.padding(12)
                        }
                        
                        // Bio
                        Text(userBio)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                           // .foregroundColor(.gray)
                    }
                    .background(Color.white)
                            .cornerRadius(8)
                            
                
                // Posts Section
              
                VStack(alignment: .leading) {
                    Text("Posts")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top)
                    ScrollView {
                    if posts.isEmpty {
                        Text("No posts yet")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(posts) { service in
                            NavigationLink(destination: PostDetailView(
                                title: service.title,
                                author: userName,
                                price: String(format: "%.2f SR", service.price),
                                images: loadImages(from: service.imageAssets),
                                description: service.description,
                                contactType: "Phone number",
                                userID: userID,
                                serviceID: service.id.uuidString
                            )) {
                                PostCard(
                                    image: loadFirstImage(from: service.imageAssets),
                                    title: service.title,
                                    author: userName,
                                    price: String(format: "%.2f SR", service.price)
                                )
                                //.padding(.horizontal)
                            }
                        }
                    }
                }
            }
                //Spacer()
                // Contact Button at bottom
                Button(action: {
                    showContactOptions()
                }) {
                    Text("Contact")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.customButtonColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            
            }.padding(12)
        
        .navigationBarHidden(true)
        .background(Color("BackgroundColor"))
        .onAppear {
            fetchUserProfile()
            fetchUserPosts()
        }
    }
    
    private func loadFirstImage(from assets: [CKAsset]?) -> UIImage? {
        guard let assets = assets,
              let firstAsset = assets.first,
              let fileURL = firstAsset.fileURL,
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }
    
    private func loadImages(from assets: [CKAsset]?) -> [UIImage] {
        guard let assets = assets else { return [] }
        return assets.compactMap { asset in
            guard let fileURL = asset.fileURL,
                  let data = try? Data(contentsOf: fileURL),
                  let image = UIImage(data: data) else {
                return nil
            }
            return image
        }
    }
    
    private func fetchUserProfile() {
        let predicate = NSPredicate(format: "userID == %@", userID)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }
                
                if let record = records?.first {
                    self.userName = record["name"] as? String ?? ""
                    self.userBio = record["bio"] as? String ?? ""
                    self.email = record["email"] as? String ?? ""
                    self.phoneNumber = record["phoneNumber"] as? String ?? ""
                    
                    if let imageAsset = record["profileImage"] as? CKAsset,
                       let fileURL = imageAsset.fileURL,
                       let imageData = try? Data(contentsOf: fileURL),
                       let image = UIImage(data: imageData) {
                        self.userImage = image
                    }
                }
                self.isLoading = false
            }
        }
    }
    
    private func fetchUserPosts() {
        let reference = CKRecord.Reference(recordID: CKRecord.ID(recordName: userID), action: .none)
        let predicate = NSPredicate(format: "user == %@", reference)
        let query = CKQuery(recordType: "post", predicate: predicate)
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                if let records = records {
                    self.posts = records.compactMap { record in
                        guard let title = record["title"] as? String,
                              let price = record["price"] as? Double,
                              let description = record["description"] as? String else {
                            return nil
                        }
                        
                        return Service(
                            id: UUID(),
                            title: title,
                            description: description,
                            price: price,
                            imageName: "",
                            user: self.userName,
                            imageAssets: record["images"] as? [CKAsset]
                        )
                    }
                }
            }
        }
    }
    
    private func showContactOptions() {
        let alert = UIAlertController(
            title: "Contact Options",
            message: "Choose how you would like to contact \(userName)",
            preferredStyle: .actionSheet
        )
        
        if !phoneNumber.isEmpty {
            alert.addAction(UIAlertAction(title: "WhatsApp: \(phoneNumber)", style: .default) { _ in
                openWhatsApp(phoneNumber: phoneNumber)
            })
        }
        
        if !email.isEmpty {
            alert.addAction(UIAlertAction(title: "Email: \(email)", style: .default) { _ in
                openEmail(email: email)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
    
    private func openWhatsApp(phoneNumber: String) {
        var formattedNumber = phoneNumber
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        
        if formattedNumber.hasPrefix("0") {
            formattedNumber = "+966" + String(formattedNumber.dropFirst())
        } else if formattedNumber.hasPrefix("966") && !formattedNumber.hasPrefix("+") {
            formattedNumber = "+" + formattedNumber
        }
        
        let whatsappURL = URL(string: "https://wa.me/\(formattedNumber)")!
        
        if UIApplication.shared.canOpenURL(whatsappURL) {
            UIApplication.shared.open(whatsappURL)
        }
    }
    
    private func openEmail(email: String) {
        let subject = "Service Inquiry"
        let mailtoURL = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
        
        if UIApplication.shared.canOpenURL(mailtoURL) {
            UIApplication.shared.open(mailtoURL)
        }
    }
} 
