import SwiftUI
import CloudKit

struct AllServicesView: View {
    @StateObject private var vm = AllServicesViewModel()
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @State private var searchText: String = ""
    @State private var showingUnbookmarkAlert = false
    @State private var selectedService: Service?
    @State private var userNames: [CKRecord.ID: String] = [:]
    @State private var isLoading = false
    @FocusState private var isSearchFocused: Bool
    @State private var showingPriceFilter = false
    @State private var maxPriceFilter: Double = 10000
    @Environment(\.presentationMode) var presentationMode
    
    private func mapService(_ service: Service) -> Service {
        var modifiedService = service
        if let userRef = service.userReference {
            modifiedService.user = userNames[userRef.recordID] ?? "Loading..."
        }
        return modifiedService
    }
    
    private func filterService(_ service: Service) -> Bool {
        let matchesSearch = searchText.isEmpty || 
            service.title.lowercased().contains(searchText.lowercased()) ||
            service.user.lowercased().contains(searchText.lowercased())
        
        let matchesPrice = service.price <= maxPriceFilter
        
        return matchesSearch && matchesPrice
    }
    
    var filteredServices: [Service] {
        vm.services.map(mapService).filter(filterService).sorted { $0.price < $1.price }
    }
    
    var body: some View {
        ZStack {
            Color.customBackground
                .edgesIgnoringSafeArea(.all)
            
            VStack() {
                // Header with title, search, and filter
                VStack(spacing: 16) {
                    // Title and back button
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.customButtonColor)
                                .font(.system(size: 20, weight: .semibold))
                        }
                        
                        Spacer()
                        
                        Text("Services")
                           // .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.customButtonColor)
                        
                        Spacer()
                        
                        Button(action: {
                            showingPriceFilter = true
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 22))
                                .foregroundColor(.customButtonColor)
                                .overlay(
                                    Group {
                                        if maxPriceFilter < 10000 {
                                            Circle()
                                                .fill(Color.customButtonColor)
                                                .frame(width: 8, height: 8)
                                                .offset(x: 10, y: -10)
                                        }
                                    }
                                )
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search services", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .focused($isSearchFocused)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .submitLabel(.search)
                    }
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                            ForEach(filteredServices) { service in
                                NavigationLink(destination: PostDetailView(
                                    title: service.title,
                                    author: service.user,
                                    price: String(format: "%.2f SR", service.price),
                                    images: loadImages(from: service.imageAssets),
                                    description: service.description,
                                    contactType: "Phone number", // You might want to make this dynamic
                                    userID: service.userReference?.recordID.recordName ?? "",
                                    serviceID: service.id.uuidString
                                )) {
                                    ServiceCard(
                                        title: service.title,
                                        author: "\(service.user)",
                                        price: service.price,
                                        imageAssets: service.imageAssets,
                                        imageKey: service.id.uuidString,
                                        onBookmarkTap: {
                                            if bookmarkManager.isBookmarked(service: service) {
                                                selectedService = service
                                                showingUnbookmarkAlert = true
                                            } else {
                                                withAnimation {
                                                    bookmarkManager.toggleBookmark(service: service)
                                                }
                                            }
                                        },
                                        isBookmarked: bookmarkManager.isBookmarked(service: service)
                                    )
                                    .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onAppear {
                                    if let userRef = service.userReference,
                                       userNames[userRef.recordID] == nil {
                                        Task {
                                            await fetchUserName(for: userRef.recordID)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .sheet(isPresented: $showingPriceFilter) {
            PriceSortView(maxPrice: $maxPriceFilter)
                .presentationDetents([.height(400)])
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
        .onAppear {
            isLoading = true
            Task {
                await vm.fetchAllServices()
                isLoading = false
            }
        }
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
    
    private func fetchUserName(for recordID: CKRecord.ID) async {
        let predicate = NSPredicate(format: "userID == %@", recordID.recordName)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
        
        do {
            let (results, _) = try await CKContainer.default().publicCloudDatabase.records(matching: query)
            if let firstResult = results.first,
               case .success(let record) = firstResult.1,
               let name = record["name"] as? String {
                await MainActor.run {
                    userNames[recordID] = name
                }
            } else {
                await MainActor.run {
                    userNames[recordID] = "Unknown User"
                }
            }
        } catch {
            await MainActor.run {
                userNames[recordID] = "Unknown User"
            }
        }
    }
}

struct AllServicesView_Previews: PreviewProvider {
    static var previews: some View {
        AllServicesView()
    }
} 
