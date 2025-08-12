import SwiftUI
import CloudKit

struct PostModel: Identifiable {
    let id: CKRecord.ID
    let title: String
    let author: String
    let price: String
    let image: UIImage?
}

struct MyPostView: View {
    @State private var selectedTab = "My Post"
    @State private var userRecordID: CKRecord.ID?
    @State private var userName: String?
    @State private var myPosts: [Service] = []
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @State private var showingUnbookmarkAlert = false
    @State private var selectedService: Service?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingICloudAlert = false
    @State private var iCloudStatus: CKAccountStatus = .couldNotDetermine
    @State private var serviceImages: [String: UIImage] = [:]
    @State private var isInRootView = true
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var vm = ServicesViewModel()
    @StateObject private var profileVM = PersonalInfoViewModel()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                Color.customBackground
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    // Top spacing
                    Spacer().frame(height: 16)
                    
                    HStack(spacing: 44) {
                        tabButton(title: "My Post")
                        tabButton(title: "Saved")
                    }
                    .padding(.bottom, 16)
                    
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if iCloudStatus != .available {
                        VStack(spacing: 16) {
                            Image(systemName: "icloud.slash")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("iCloud Account Required")
                                .font(.headline)
                            
                            Text("Please sign in to your iCloud account in Settings to access your posts.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                openSettings()
                            }) {
                                Text("Open Settings")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                 
                            Text(error)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.red)
                            
                            Button(action: {
                                errorMessage = nil
                                checkICloudAccountStatus()
                            }) {
                                Text("Try Again")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                if selectedTab == "My Post" {
                                    if myPosts.isEmpty {
                                        VStack {
                                            Image(systemName: "doc.text")
                                                .font(.system(size: 50))
                                                .foregroundColor(.gray)
                                                .padding()
                                            
                                            Text("No posts yet")
                                                .foregroundColor(.gray)
                                                .font(.headline)
                                            
                                            Text("Your posted services will appear here")
                                                .foregroundColor(.gray)
                                                .font(.subheadline)
                                                .padding(.top, 5)
                                        }
                                    } else {
                                        ForEach(myPosts) { service in
                                            PostCard(
                                                image: serviceImages[service.id.uuidString],
                                                title: service.title,
                                                author: userName.map { "\($0)" } ?? "Loading...",
                                                price: String(format: "%.2f SR", service.price)
                                            )
                                            .padding(.horizontal)
                                        }
                                    }
                                } else {
                                    let bookmarkedServices = bookmarkManager.getAllBookmarks()
                                    if bookmarkedServices.isEmpty {
                                        VStack {
                                            Image(systemName: "bookmark")
                                                .resizable()
                                                .frame(width: 14, height: 18)
                                                .foregroundColor(.gray)
                                                .padding()
                                            
                                            Text("No saved services yet")
                                                .foregroundColor(.gray)
                                                .font(.headline)
                                            
                                            Text("Bookmarked services will appear here")
                                                .foregroundColor(.gray)
                                                .font(.subheadline)
                                                .padding(.top, 5)
                                        }
                                        .padding()
                                    } else {
                                        ForEach(bookmarkedServices) { service in
                                            ServiceCard(
                                                title: service.title,
                                                author: service.user.isEmpty ? "Loading..." : " \(service.user)",
                                                price: service.price,
                                                imageAssets: service.imageAssets,
                                                imageKey: service.id.uuidString,
                                                onBookmarkTap: {
                                                    selectedService = service
                                                    showingUnbookmarkAlert = true
                                                },
                                                isBookmarked: true
                                            )
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
            
            .alert(isPresented: $showingUnbookmarkAlert) {
                Alert(
                    title: Text("Remove Bookmark"),
                    message: Text("Are you sure you want to remove this service from your bookmarks?"),
                    primaryButton: .destructive(Text("Remove")) {
                        if let service = selectedService {
                            withAnimation {
                                bookmarkManager.toggleBookmark(service: service)
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }   .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.customButtonColor)
                    }
                }
            }

        .onAppear {
            checkICloudAccountStatus()
            vm.fetchServices()
            Task {
                await profileVM.fetchProfile()
            }
        }
    }
    
    private func checkICloudAccountStatus() {
        isLoading = true
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                self.iCloudStatus = status
                switch status {
                case .available:
                    self.fetchUserRecordID()
                case .noAccount:
                    self.errorMessage = "No iCloud account found. Please sign in to your iCloud account in Settings."
                    self.isLoading = false
                case .restricted:
                    self.errorMessage = "iCloud access is restricted. Please check your device settings."
                    self.isLoading = false
                case .couldNotDetermine:
                    self.errorMessage = "Could not determine iCloud account status. Please try again."
                    self.isLoading = false
                @unknown default:
                    self.errorMessage = "Unknown iCloud account status. Please try again."
                    self.isLoading = false
                }
            }
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private func fetchUserRecordID() {
        CKContainer.default().fetchUserRecordID { recordID, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error fetching user: \(error.localizedDescription)"
                    self.isLoading = false
                } else if let recordID = recordID {
                    self.userRecordID = recordID
                    Task {
                        await self.fetchUserName(for: recordID)
                        await self.fetchMyPosts(for: recordID)
                    }
                }
            }
        }
    }
    
    private func fetchUserName(for recordID: CKRecord.ID) async {
                let predicate = NSPredicate(format: "userID == %@", recordID.recordName)
                let query = CKQuery(recordType: "UserProfile", predicate: predicate)
                
        do {
            let (results, _) = try await CKContainer.default().publicCloudDatabase.records(matching: query)
                if let firstResult = results.first,
                   case .success(let record) = firstResult.1,
                   let name = record["name"] as? String {
                    await MainActor.run {
                        self.userName = name
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching user profile: \(error.localizedDescription)"
            }
        }
    }
    
    private func loadImage(from assets: [CKAsset]?, for serviceId: String) {
        guard let firstAsset = assets?.first,
              let fileURL = firstAsset.fileURL else {
            return
        }
        
        do {
            let imageData = try Data(contentsOf: fileURL)
            if let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    serviceImages[serviceId] = image
                }
            }
        } catch {
            print("Error loading image: \(error)")
        }
    }
    
    private func fetchMyPosts(for recordID: CKRecord.ID) async {
        let reference = CKRecord.Reference(recordID: recordID, action: .none)
        let predicate = NSPredicate(format: "user == %@", reference)
        let query = CKQuery(recordType: "post", predicate: predicate)
        
        do {
            let (results, _) = try await CKContainer.default().publicCloudDatabase.records(matching: query)
            var fetchedPosts: [Service] = []
            
            for (_, result) in results {
                if case .success(let record) = result,
                   let title = record["title"] as? String,
                   let price = record["price"] as? Double,
                   let description = record["description"] as? String {
                    let service = Service(
                        id: UUID(),
                        title: title,
                        description: description,
                        price: price,
                        imageName: record["images"] as? String ?? "defaultImage",
                        user: userName ?? "Loading...",
                        imageAssets: record["images"] as? [CKAsset]
                    )
                    fetchedPosts.append(service)
                    
                    // Load image for the service
                    if let imageAssets = record["images"] as? [CKAsset] {
                        loadImage(from: imageAssets, for: service.id.uuidString)
                    }
                }
            }
            
            await MainActor.run {
                self.myPosts = fetchedPosts
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Error fetching posts: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func tabButton(title: String) -> some View {
        VStack(spacing: 8) {
            Button(action: {
                selectedTab = title
            }) {
                Text(title)
                    .font(.custom("SF Pro", size: 17))
                    .fontWeight(.bold)
                    .foregroundColor(selectedTab == title ? Color.customButtonColor : .black)
            }

            Rectangle()
                .fill(selectedTab == title ? Color.customButtonColor : Color.clear)
                .frame(height: 3)
                .frame(maxWidth: .infinity)
        }
    }
}

struct MyPostView_Previews: PreviewProvider {
    static var previews: some View {
        MyPostView()
    }
}
