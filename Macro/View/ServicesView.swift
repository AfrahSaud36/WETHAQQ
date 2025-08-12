import SwiftUI
import CloudKit

// Main view containing service cards
struct ServicesView: View {
    @StateObject private var vm = ServicesViewModel()
    @State private var searchText = ""
    @StateObject private var profileVM = PersonalInfoViewModel()
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @State private var currentIndex = 0
    @State private var offset: CGFloat = 0
    @State private var showingProfileAlert = false
    @State private var navigateToProfile = false
    
    let cardWidth: CGFloat = 260
    let cardSpacing: CGFloat = 16
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    struct Card: Identifiable {
        let id = UUID()
        let color: Color
        let image: String
        let title1: String
        let title2: String
    }
    
    // Sample cards data
    let repeatingCards: [Card] = [
        Card(color: Color("babyblue"), image: "card1image", title1: "Help is", title2: "just one \ntap away !"),
        Card(color: Color("blue"), image: "", title1: "", title2: "We bring help \ncloser to you!")
    ]

    var body: some View {
        NavigationStack {
            VStack {
                // Header with welcome message and add button
                Spacer().frame(height: 65)
                HStack {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        if let image = profileVM.profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                                .clipShape(Circle())
                        }
                    }
                    
                    Text("Welcome \(profileVM.name)")
                        .font(.system(size: 17))
                        .fontWeight(.bold)
                        .foregroundColor(.primaryText)
                    
                    Spacer()
                    
                    Button(action: {
                        if profileVM.name.isEmpty || profileVM.email.isEmpty {
                            showingProfileAlert = true
                        } else {
                            navigateToProfile = true
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .foregroundColor(.customButtonColor)
                    }
                }
                .padding([.leading, .trailing])
                
                // Adding space above the cards to move them down a bit
                //  Spacer().frame(height: 16) // Added space to push cards down
                                VStack{
                                    Spacer().frame(height: 35)

                GeometryReader { geometry in
                    HStack(spacing: 16) {
                        ForEach(repeatingCards + repeatingCards) { card in // Duplicate cards for continuous scrolling
                            VStack {
                                ZStack {
                                    card.color
                                        .frame(width: cardWidth, height: 150)
                                        .cornerRadius(16)
                                    
                                    if !card.image.isEmpty {
                                        Image(card.image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                            .foregroundColor(.white)
                                            .offset(x: 80, y: 20)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        if !card.title1.isEmpty {
                                            Text(card.title1)
                                                .foregroundColor(Color("blue"))
                                                .font(.system(size: 28))
                                                .fontWeight(.bold)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                        }
                                        
                                        Text(card.title2)
                                            .foregroundColor(.white)
                                            .font(.system(size: card.title1.isEmpty ? 25 : 20))
                                            .fontWeight(.medium)
                                            .lineSpacing(4)
                                            .frame(maxWidth: .infinity, alignment: card.title1.isEmpty ? .center : .leading)
                                            .multilineTextAlignment(card.title1.isEmpty ? .center : .leading)
                                    }
                                    .padding(.horizontal, 25)
                                    .padding(.vertical, 20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .frame(width: cardWidth)
                        }
                    }
                    .padding(.leading, 12) // Add padding to move cards right
                    
                    .offset(x: offset)
                    .animation(.easeInOut(duration: 0.5), value: offset)
                    .onReceive(timer) { _ in
                        // Move by one card width + spacing
                        offset -= (cardWidth + cardSpacing)
                        
                        // Reset when we've scrolled through all original cards
                        if abs(offset) >= (cardWidth + cardSpacing) * CGFloat(repeatingCards.count) {
                            offset = 0
                        }
                    }     }}
                
              
                // Services title and see all button
                VStack(  spacing: 16){
                HStack {
                    Text("Services")
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                    Spacer()
                    NavigationLink(destination: AllServicesView()) {
                        Text("See All")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(.customButtonColor)
                    }
                }        .padding([.leading, .trailing])
                
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ServiceCategoryView(title: "Tutoring Sessions", category: "tutoringSessionsID", imageName: "tut", vm: vm)
                        ServiceCategoryView(title: "Test Preparation", category: "testPreparationID", imageName: "test", vm: vm)
                        ServiceCategoryView(title: "Homework Assistance", category: "homeworkAssistanceID", imageName: "homework", vm: vm)
                        ServiceCategoryView(title: "Soft Skills", category: "softSkillsID", imageName: "soft", vm: vm)
                    }
                    .padding(.leading ,12)
                }
                
            }
                Spacer()
                    .frame(height: 54)
                // Recently Viewed Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recently viewed")
                        .font(.system(size: 17, weight: .bold))
    
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            RecentlyViewedCard(
                                imageName: "soft",
                                title: "Math Touter",
                                name: "Essa Ahmed",
                                price: "200SR"
                            )
                            
                            RecentlyViewedCard(
                                imageName: "smile",
                                title: "Math Touter",
                                name: "Essa Ahmed",
                                price: "200SR"
                            )
                        }
                        //.padding(.horizontal)
                    }
                } .padding([.leading, .trailing])
                Spacer()
                    .frame(height: 80)
                
               

               // Spacer()
            }
            .alert("Complete Your Profile", isPresented: $showingProfileAlert) {
                Button("Complete Profile") {
                    navigateToProfile = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please complete your profile information before creating a post.")
            }
            .navigationDestination(isPresented: $navigateToProfile) {
                if profileVM.name.isEmpty || profileVM.email.isEmpty {
                    PersonalInfoView()
                } else {
                    AddPost()
                }
            }
            .onAppear {
                vm.fetchServices()
                Task {
                    await profileVM.fetchProfile()
                }
            }
            .background(Color("BackgroundColor"))
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    
    // PostCard for displaying service information

    // Service category card view
    struct ServiceCategoryView: View {
        var title: String
        var category: String
        var imageName: String
        var vm: ServicesViewModel
        
        
        private var splitTitle: String {
               let components = title.components(separatedBy: " ")
               guard components.count >= 2 else { return title }
               return "\(components[0])\n\(components[1...].joined(separator: " "))"
           }
        
        var body: some View {
            NavigationLink(destination: ServiceCategoryDetailView(category: category, vm: vm, userID: "defaultUserID")) {
                VStack(spacing: 8) {
                    ZStack(alignment: .top) {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 100)
                            .offset(y: -39)
                        
                        Text(splitTitle)
                            .font(.system(size: 12, weight: .medium))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .offset(y: 69)
                            .foregroundColor(.black)
                        
                    }}
                    .padding()
                    .frame(width: 112, height: 118)
                    .background(Color.white)
                    .cornerRadius(12)
                
            }
        }
    }
    
    // Service category detail view
    struct ServiceCategoryDetailView: View {
        var category: String
        @ObservedObject var vm: ServicesViewModel
        var userID: String
        
        @StateObject private var bookmarkManager = BookmarkManager.shared
        @State private var showingUnbookmarkAlert = false
        @State private var selectedService: Service?
        @State private var userNames: [CKRecord.ID: String] = [:]
        @State private var isLoading = false
        @State private var showingPriceFilter = false
        @State private var maxPriceFilter: Double = 10000
        @State private var searchText: String = ""
        @Environment(\.presentationMode) var presentationMode
        
        // Helper function to get formatted category name
        private func getCategoryName() -> String {
            switch category {
            case "tutoringSessionsID":
                return "Tutoring Sessions"
            case "testPreparationID":
                return "Test Preparation"
            case "homeworkAssistanceID":
                return "Homework Assistance"
            case "softSkillsID":
                return "Soft Skills"
            default:
                return "Services"
            }
        }
        
        private var filteredServices: [CKRecord] {
            let services = vm.filterServicesByCategory(category)
            return services.filter { record in
                var matches = true
                
                // Apply search text filter
                if !searchText.isEmpty {
                    if let title = record["title"] as? String {
                        matches = matches && title.lowercased().contains(searchText.lowercased())
                    } else {
                        matches = false
                    }
                }
                
                // Apply price filter
                if let price = record["price"] as? Double {
                    matches = matches && price <= maxPriceFilter
                } else {
                    matches = false
                }
                
                return matches
            }
            .sorted { first, second in
                let price1 = first["price"] as? Double ?? 0.0
                let price2 = second["price"] as? Double ?? 0.0
                return price1 < price2
            }
        }
        
        var body: some View {
            ZStack {
                Color.customBackground
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header with category name and filter button
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
                            Text(getCategoryName())
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
                        }                                .navigationBarBackButtonHidden(true)

                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondaryText)
                            
                            TextField("Search services", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .foregroundColor(.primaryText)
                        }
                        .padding(8)
                        .background(Color.formBackground)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                   // .background(Color.white)
                  //  .shadow(color: Color.black.opacity(0.05), radius: 3, y: 2)
                    
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                                ForEach(filteredServices, id: \.recordID) { record in
                                    let userRef = record["user"] as? CKRecord.Reference
                                    let userName = userNames[userRef?.recordID ?? CKRecord.ID(recordName: "unknown")] ?? "Loading..."
                                    
                                    let service = Service(
                                        id: UUID(),
                                        title: record["title"] as? String ?? "No Title",
                                        description: record["description"] as? String ?? "No Description",
                                        price: record["price"] as? Double ?? 0.0,
                                        imageName: record["images"] as? String ?? "defaultImage",
                                        user: userName
                                    )
                                    
                                    NavigationLink(destination: PostDetailView(
                                        title: service.title,
                                        author: service.user,
                                        price: String(format: "%.2f SR", service.price),
                                        images: loadImages(from: record["images"] as? [CKAsset]),
                                        description: service.description,
                                        contactType: "Phone number",
                                        userID: userRef?.recordID.recordName ?? "",
                                        serviceID: service.id.uuidString
                                    )) {
                                        ServiceCard(
                                            title: service.title,
                                            author: " \(service.user)",
                                            price: service.price,
                                            imageAssets: record["images"] as? [CKAsset],
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
                                        if let userRef = userRef, userNames[userRef.recordID] == nil {
                                            fetchUserName(for: userRef.recordID)
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
                fetchInitialUserNames()
            }
        }
        
        private func fetchInitialUserNames() {
            let records = vm.filterServicesByCategory(category)
            let userRefs = records.compactMap { $0["user"] as? CKRecord.Reference }
            
            let group = DispatchGroup()
            
            for userRef in userRefs {
                group.enter()
                fetchUserName(for: userRef.recordID) {
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                isLoading = false
            }
        }
        
        private func fetchUserName(for recordID: CKRecord.ID, completion: (() -> Void)? = nil) {
            let predicate = NSPredicate(format: "userID == %@", recordID.recordName)
            let query = CKQuery(recordType: "UserProfile", predicate: predicate)
            
            Task {
                do {
                    let (results, _) = try await CKContainer.default().publicCloudDatabase.records(matching: query)
                    await MainActor.run {
                        if let firstResult = results.first,
                           case .success(let record) = firstResult.1,
                           let name = record["name"] as? String {
                            userNames[recordID] = name
                        } else {
                            userNames[recordID] = "Unknown User"
                        }
                        completion?()
                    }
                } catch {
                    await MainActor.run {
                        userNames[recordID] = "Unknown User"
                        completion?()
                    }
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
    }
    
    // Helper view to break down the complex ServiceCard creation
    private struct ServiceCardView: View {
        let record: CKRecord
        let userNames: [CKRecord.ID: String]
        let bookmarkManager: BookmarkManager
        let onUnbookmark: (Service) -> Void
        
        var body: some View {
            let userRef = record["user"] as? CKRecord.Reference
            let userName = userNames[userRef?.recordID ?? CKRecord.ID(recordName: "unknown")] ?? "Loading..."
            
            let service = Service(
                id: UUID(),
                title: record["title"] as? String ?? "No Title",
                description: record["description"] as? String ?? "No Description",
                price: record["price"] as? Double ?? 0.0,
                imageName: record["images"] as? String ?? "defaultImage",
                user: userName
            )
            
            
            ServiceCard(
                title: service.title,
                author: "\(service.user)",
                price: service.price,
                imageAssets: record["images"] as? [CKAsset],
                imageKey: service.id.uuidString,
                onBookmarkTap: {
                    if bookmarkManager.isBookmarked(service: service) {
                        onUnbookmark(service)
                    } else {
                        withAnimation {
                            bookmarkManager.toggleBookmark(service: service)
                        }
                    }
                },
                isBookmarked: bookmarkManager.isBookmarked(service: service)
            )
        }
    }
}

// Preview provider
struct ServicesView_Previews: PreviewProvider {
    static var previews: some View {
        ServicesView()
    }
}

// Add RecentlyViewedCard view and extensions at the end of the file
struct RecentlyViewedCard: View {
    let imageName: String
    let title: String
    let name: String
    let price: String
    
    var body: some View {
        VStack(spacing: 11) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 180, height: 100)
                .clipped()
                .cornerRadius(20, corners: [.topLeft, .topRight])
               .padding(.top, -20)
            
            VStack{
                HStack( spacing: 50) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color("blue"))
                        Text(name)
                            .font(.system(size: 11))
                            .foregroundColor(.black)
                    }
                    
                    Image(systemName: "bookmark")
                        .resizable()
                        .frame(width: 14, height: 18)
                        .foregroundColor(.black)
                }}
                
                HStack {
                    Text(price)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.black)
                        .padding(.leading, 120)
                }

            }
        
        .frame(width: 174, height: 190)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
}

// Corner radius extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
