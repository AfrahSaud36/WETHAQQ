import SwiftUI
import CloudKit

struct Comment: Identifiable {
    let id: String
    let name: String
    let text: String
    var replies: [Comment]
    let serviceID: String
    let imageData: Data?  // Store image as Data
    let creationDate: Date
    
    init(record: CKRecord) {
        self.id = record.recordID.recordName
        self.name = record["name"] as? String ?? ""
        self.text = record["text"] as? String ?? ""
        self.serviceID = record["serviceID"] as? String ?? ""
        self.replies = []
        self.creationDate = record.creationDate ?? Date()  // Use CloudKit's creation date
        if let asset = record["imageData"] as? CKAsset,
           let fileURL = asset.fileURL {
            self.imageData = try? Data(contentsOf: fileURL)
        } else {
            self.imageData = nil
        }
    }
    
    init(id: String = UUID().uuidString, name: String, text: String, serviceID: String, imageData: Data? = nil, replies: [Comment] = []) {
        self.id = id
        self.name = name
        self.text = text
        self.serviceID = serviceID
        self.imageData = imageData
        self.replies = replies
        self.creationDate = Date()
    }
}

struct PostDetailView: View {
    
    @State private var comments: [Comment] = []
    @State private var isLoadingComments = false
    
    @State private var userName: String = ""
    @State private var userImage: UIImage?
    @State private var showProfileAlert = false
       
    
    @State private var newComment = ""
    @State private var replyToComment: Comment?
    @State private var showFullDescription = false
    
    var title: String
    var author: String
    var price: String
    var images: [UIImage]  // نعرض مجموعة من الصور هنا
    var description: String
    
    //newwwww
    @State private var showContactInfo = false
    @State private var contactInfo = ""
    let contactType: String // يجب تمريرها من الشاشة السابقة
    let userID: String // يجب تمريرها من الشاشة السابقة
    
    
    
    let serviceID:String // comeent
    @StateObject private var profileVM = PersonalInfoViewModel()

    @StateObject private var vm = PersonalInfoViewModel()

    
    
    
    
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        // NavigationView {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        // عرض الصور باستخدام TabView للتمرير بين الصور
                        TabView {
                            ForEach(images, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 230)
                                    .clipped()
                                //  .cornerRadius(8)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                        .frame(height: 230)
                        
                        HStack {
                            Text(title)
                                .foregroundColor(.customButtonColor)
                                .font(.title2)
                                .bold()
                            
                            Spacer()
                            
                            Text(price)
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                                .padding(6)
                            Button(action: {
                                // Add bookmark functionality here
                            }) {
                                Image(systemName: "bookmark")
                                    .resizable()
                                    .frame(width: 20, height: 24)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(8)
                        
                        HStack {
                            NavigationLink(destination: ProviderView(userID: userID)) {
                            if let image = vm.profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.gray)
                                    .clipShape(Circle())
                            }
                         
                                Text(author)
                                    .foregroundColor(.black)
                            }
                            Spacer()
                        }
                        .padding(8)
                    }
                    //.padding(16)
                    .background(Color.white)
                    .cornerRadius(8)
                    // .padding(.horizontal)
                    
                  
                    VStack{
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Description")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.customButtonColor)
                                .padding(8)

                            Text(description)
                                .lineLimit(showFullDescription ? nil : 2)
                                .animation(.easeInOut, value: showFullDescription)
                                .padding(8)

                            if description.count > 100 {
                                Button(action: {
                                    withAnimation {
                                        showFullDescription.toggle()
                                    }
                                }) {
                                    Text(showFullDescription ? "Read less" : "Read more")
                                        .font(.caption)
                                        .foregroundColor(.customButtonColor)
                                        .padding(12)
                                        
                                }
                            }

                            
                          Spacer()
                            // قسم التعليقات
//                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Comments")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.customButtonColor)
                                        .padding(8)

                                    Spacer()
                                    
                                    NavigationLink(destination: AllCommentsView(comments: $comments, replyToComment: $replyToComment, newComment: $newComment, serviceID: serviceID)) {
                                        Text("See All")
                                            .font(.footnote)
                                            .fontWeight(.bold)
                                            .foregroundColor(.customButtonColor)
                                            .padding(8)

                                    }
                                }
                                
                                if comments.isEmpty {
                                    Text("No comments yet.")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                   .padding(8)

                                } else {
                                    ForEach(comments.prefix(2)) { comment in
                                        CommentView(comment: comment)
                                            .padding(8)

                                    }
                                }
                          
                        }
                }.background(Color.white)
                        .cornerRadius(8)
                    
                    Spacer().frame(height: 80) // يترك مساحة لزر Contact
                    
                    
                    
                    
                }
                .padding(12)
            }
            .onAppear {
                fetchComments()
            }
            
            VStack {
                Button(action: {
                    fetchContactInfo()
                }) {
                    Text("Contact")
                        .frame(maxWidth: .infinity )
                        .padding()
                        .background(Color.customButtonColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                       // .padding(.horizontal)
                }
                .background(Color.customBackground)
                .alert(isPresented: $showContactInfo) {
                    Alert(
                        title: Text("Contact"),
                        message: Text(contactInfo),
                        dismissButton: .default(Text("OK"))
                
                    ) }}.padding(12)
            
            // زر التواصل ثابت في الأسفل
//            VStack {
//                Button(action: {
//
//
//            }) {
//                Text("Contact")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.customButtonColor)
//                    .foregroundColor(.white)
//                    .cornerRadius(12)
//                    .padding(.horizontal)
//            } .background(Color.customBackground)
//
//            }
            
        }
        
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left") // السهم فقط بدون "Back"
                        .foregroundColor(Color.customButtonColor)
                }
            }
        }
        
    }
    
    // newwwwwwww
   func fetchContactInfo() {
        let recordName = userID
        let predicate = NSPredicate(format: "userID == %@", recordName)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
        
        let desiredKey = contactType == "Phone number" ? "phoneNumber" : "email"
        
        CKContainer.default().publicCloudDatabase.fetch(withQuery: query) { result in
            switch result {
            case .success(let matchResults):
                if let record = matchResults.matchResults.first?.1 {
                    switch record {
                    case .success(let userProfile):
                        DispatchQueue.main.async {
                            if let contactValue = userProfile[desiredKey] as? String {
                                openContactApp(contactValue: contactValue)
                            } else {
                                showAlert(message: "Contact information not available")
                            }
                        }
                    case .failure(let error):
                        print("Error fetching user profile: \(error.localizedDescription)")
                        showAlert(message: "Error fetching contact information")
                    }
                }
            case .failure(let error):
                print("Error querying user profile: \(error.localizedDescription)")
                showAlert(message: "Error fetching contact information")
            }
        }
    }

    private func openContactApp(contactValue: String) {
        if contactType == "Phone number" {
            // 1. إزالة جميع المسافات والرموز غير الرقمية
            var phoneNumber = contactValue
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "-", with: "")
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
            
            // 2. إذا كان الرقم يبدأ بـ 0 (مثل 0564689796)، نستبدله بـ +966
            if phoneNumber.hasPrefix("0") {
                phoneNumber = "+966" + String(phoneNumber.dropFirst())
            }
            // 3. إذا كان الرقم يبدأ بـ 966 بدون + (مثل 966564689796)، نضيف +
            else if phoneNumber.hasPrefix("966") && !phoneNumber.hasPrefix("+") {
                phoneNumber = "+" + phoneNumber
            }
            // 4. إذا كان الرقم لا يحتوي على + أو 0، نعتبره غير صالح
            else if !phoneNumber.hasPrefix("+") {
                showAlert(message: "Invalid phone number. It must start with +966 or 05 (e.g., +966564689796)")
                return
            }
            
            // 5. فتح واتساب بالرابط الصحيح
            let whatsappURL = URL(string: "https://wa.me/\(phoneNumber)")!
            
            if UIApplication.shared.canOpenURL(whatsappURL) {
                UIApplication.shared.open(whatsappURL)
            } else {
                showAlert(message: "WhatsApp is not installed. Phone number: \(phoneNumber)")
            }
        } else {
                       let email = contactValue
                       let subject = " about your post: \(title)"
                       let mailtoURL = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
           
                       if UIApplication.shared.canOpenURL(mailtoURL) {
                           UIApplication.shared.open(mailtoURL)
                       } else {
                           showAlert(message: "No email app is installed. Provider's contact email: \(email)")                       }
        }
    }
    
//    private func showAlert(message: String) {
//        DispatchQueue.main.async {
//            contactInfo = message
//            showContactInfo = true
//        }
//    }
//
    private func showAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "تنبيه",
                message: message,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Copy Email", style: .default) { _ in
                UIPasteboard.general.string = message.components(separatedBy: ": ").last ?? ""
            })
            
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            
            // الحصول على النافذة الحالية (iOS 15+ compatible)
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                return
            }
            
            rootViewController.present(alert, animated: true)
        }
    }
    
    // Add these functions for CloudKit operations
    private func saveComment(text: String, name: String) {
        // Convert profile image to Data
        let imageData = profileVM.profileImage?.jpegData(compressionQuality: 0.5)
        
        // Create and show comment instantly
        let newComment = Comment(
            id: UUID().uuidString,
            name: name,
            text: text,
            serviceID: serviceID,
            imageData: imageData
        )
        comments.insert(newComment, at: 0)
        
        // Save to CloudKit
        let record = CKRecord(recordType: "Comment")
        record["name"] = name
        record["text"] = text
        record["serviceID"] = serviceID
        
        // Save image data if available
        if let imageData = imageData,
           let tempURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(UUID().uuidString + ".jpg") {
            try? imageData.write(to: tempURL)
            record["imageData"] = CKAsset(fileURL: tempURL)
        }
        
        CKContainer.default().publicCloudDatabase.save(record) { _, _ in }
    }
    
    private func fetchComments() {
        let predicate = NSPredicate(format: "serviceID == %@", serviceID)
        let query = CKQuery(recordType: "Comment", predicate: predicate)
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, _ in
            guard let records = records else { return }
            
            DispatchQueue.main.async {
                self.comments = records.map { Comment(record: $0) }
            }
        }
    }
    
    private func deleteComment(_ comment: Comment) {
        // Verify this is the user's own comment
        guard comment.name == profileVM.name else { return }
        
        // Remove from UI immediately
        withAnimation {
            comments.removeAll { $0.id == comment.id }
        }
        
        // Delete from CloudKit in background
        Task {
            let recordID = CKRecord.ID(recordName: comment.id)
            do {
                try await CKContainer.default().publicCloudDatabase.deleteRecord(withID: recordID)
            } catch {
                print("Error deleting comment: \(error.localizedDescription)")
                // If deletion fails, add the comment back to UI
                await MainActor.run {
                    withAnimation {
                        comments.append(comment)
                    }
                }
            }
        }
    }

    // Update the comment view to include delete button for own comments
    private func CommentView(comment: Comment) -> some View {
        HStack(alignment: .top, spacing: 8) {
            // Show profile image if available
            if let image = profileVM.profileImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(comment.name)
                        .font(.subheadline)
                        .bold()
                    
                    Spacer()
                    
//                    if comment.name == profileVM.name {
//                        Button(action: {
//                            deleteComment(comment)
//                        }) {
//                            Image(systemName: "xmark")
//                                .foregroundColor(.gray)
//                                .font(.caption)
//                        }
//                    }
                    
                }
                
                Text(comment.text)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                Text(comment.creationDate.formattedDate())
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}
    
    
    // ✅ لتدوير زوايا معينة فقط
    extension View {
        func cornerRadius2(_ radius: CGFloat, corners: UIRectCorner) -> some View {
            clipShape(RoundedCorner2(radius: radius, corners: corners))
        }
    }
    
    struct RoundedCorner2: Shape {
        var radius: CGFloat
        var corners: UIRectCorner
        
        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            return Path(path.cgPath)
        }
    }
// للتعامل مع روابط الواتساب والبريد
extension String {
    var whatsappFormat: String {
        self.replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
    }
}
    struct AllCommentsView: View {
        @Binding var comments: [Comment]
        @Binding var replyToComment: Comment?
        @Binding var newComment: String
        let serviceID: String
        
        @StateObject private var profileVM = PersonalInfoViewModel()
        @State private var showProfileIncompleteAlert = false
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(comments) { comment in
                            CommentView(comment: comment)
                        }
                    }
                }
                
                Divider()
                
                // Comment input section
                            VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 8) {
                        if let image = profileVM.profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.gray)
                        }
                        
                        ZStack(alignment: .trailing) {
                            TextField(replyToComment != nil ? "Reply to \(replyToComment!.name)..." : "Add a comment...", text: $newComment)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray6))
                                .cornerRadius(20)
                            
                            Button(action: {
                                Task {
                                    await profileVM.fetchProfile()
                                    
                                    let trimmed = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
                                    guard !trimmed.isEmpty else { return }
                                    
                                    if profileVM.name.isEmpty || profileVM.profileImage == nil {
                                        showProfileIncompleteAlert = true
                                        return
                                    }
                                    
                                    if let replyTo = replyToComment {
                                        if let index = comments.firstIndex(where: { $0.id == replyTo.id }) {
                                            comments[index].replies.append(Comment(name: profileVM.name, text: trimmed, serviceID: serviceID))
                                        }
                                        replyToComment = nil
                                    } else {
                                        saveComment(text: trimmed, name: profileVM.name)
                                    }
                                    
                                    newComment = ""
                                }
                            }) {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.customButtonColor)
                            }
                            .padding(.trailing, 12)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("All Comments")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .onAppear {
                fetchComments()
            }
            .alert(isPresented: $showProfileIncompleteAlert) {
                Alert(
                    title: Text("Incomplete Profile"),
                    message: Text("Please complete your name and add a profile picture before writing a comment."),
                    dismissButton: .default(Text("OK"))

                )
            }
        }
        
        private func saveComment(text: String, name: String) {
            let record = CKRecord(recordType: "Comment")
            record["name"] = name
            record["text"] = text
            record["serviceID"] = serviceID
            
            CKContainer.default().publicCloudDatabase.save(record) { (record, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error saving comment: \(error.localizedDescription)")
                        return
                    }
                    
                    if let savedRecord = record {
                        let newComment = Comment(record: savedRecord)
                        comments.append(newComment)
                    }
                }
            }
        }
        
        private func fetchComments() {
            let predicate = NSPredicate(format: "serviceID == %@", serviceID)
            let query = CKQuery(recordType: "Comment", predicate: predicate)
            
            CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { [self] (records, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error fetching comments: \(error.localizedDescription)")
                        return
                    }
                    
                    if let records = records {
                        self.comments = records.map { Comment(record: $0) }
                    }
                }
            }
        }
        
        private func CommentView(comment: Comment) -> some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    if let image = profileVM.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(comment.name)
                                .font(.subheadline)
                                .bold()
                            
                            Spacer()
                            
                            // Only show xmark for user's own comments
                            if comment.name == profileVM.name {
                                Button(action: {
                                    deleteComment(comment)
                                }) {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                            }
                        }
                        
                        Text(comment.text)
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        
                        Text(comment.creationDate.formattedDate())
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Button("Reply") {
                            replyToComment = comment
                        }
                        .font(.caption)
                        .foregroundColor(.customButtonColor)
                    }
                }
                
                // Replies section
                ForEach(comment.replies) { reply in
                    HStack(alignment: .top, spacing: 8) {
                        Spacer().frame(width: 40)
                        if let image = profileVM.profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(reply.name)
                                .font(.caption)
                                .bold()
                            Text(reply.text)
                                .font(.caption)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
        
        private func deleteComment(_ comment: Comment) {
            // Verify this is the user's own comment
            guard comment.name == profileVM.name else { return }
            
            // Remove from UI immediately
            withAnimation {
                comments.removeAll { $0.id == comment.id }
            }
            
            // Delete from CloudKit in background
            Task {
                let recordID = CKRecord.ID(recordName: comment.id)
                do {
                    try await CKContainer.default().publicCloudDatabase.deleteRecord(withID: recordID)
                } catch {
                    print("Error deleting comment: \(error.localizedDescription)")
                    // If deletion fails, add the comment back to UI
                    await MainActor.run {
                        withAnimation {
                            comments.append(comment)
                                    }
                                }
                            }
                        }
                    }
                }
                
    struct CommentView: View {
        let comment: Comment
        @StateObject private var profileVM = PersonalInfoViewModel()

        var body: some View {
            HStack(alignment: .top, spacing: 8) {
                if let image = profileVM.profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.gray)
                }
                        
                VStack(alignment: .leading, spacing: 6) {
                    Text(comment.name)
                        .font(.subheadline)
                        .bold()
                    Text(comment.text)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    
                    Text(comment.creationDate.formattedDate())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }





// للمعاينة
//struct PostDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostDetailView()
//    }
//}
//

extension Date {
    func formattedDate() -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .weekOfMonth, .month, .year], from: self, to: now)
        
        if let years = components.year, years > 0 {
            return years == 1 ? "1 year ago" : "\(years) years ago"
        }
        
        if let months = components.month, months > 0 {
            return months == 1 ? "1 month ago" : "\(months) months ago"
        }
        
        if let weeks = components.weekOfMonth, weeks > 0 {
            return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
        }
        
        if let days = components.day, days > 0 {
            return days == 1 ? "1 day ago" : "\(days) days ago"
        }
        
        return "Today"
    }
}


