import SwiftUI

struct BookmarksView: View {
    @StateObject private var bookmarkManager = BookmarkManager()
    @State private var showingUnbookmarkAlert = false
    @State private var selectedService: Service?
    
    var body: some View {
        VStack {
            Text("Bookmarked Services")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            if bookmarkManager.bookmarkedServices.isEmpty {
                VStack {
                    Image(systemName: "bookmark.slash")
                        .resizable()
                        .frame(width: 14, height: 18)
                        .foregroundColor(.gray)
                        .padding()
                    
                    Text("No bookmarked services yet")
                        .foregroundColor(.gray)
                        .font(.headline)
                    
                    Text("Services you bookmark will appear here")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .padding(.top, 5)
                }
                .padding()
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 15) {
                        ForEach(Array(bookmarkManager.bookmarkedServices), id: \.self) { service in
                            HStack {
                                PostCard(
                                    image: UIImage(systemName: service.imageName),
                                    title: service.title,
                                    author: "\(service.user)",
                                    price: String(format: "%.2f SR", service.price)
                                )
                                .frame(width: 340, height: 120)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                
                                Button(action: {
                                    selectedService = service
                                    showingUnbookmarkAlert = true
                                }) {
                                    Image(systemName: "bookmark.fill")
                                        .resizable()
                                        .frame(width: 14, height: 18)
                                        .foregroundColor(.blue)
                                        .padding(.trailing, 10)
                                }
                            }
                            .frame(width: 380, height: 120)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.vertical)
                }
                .animation(.easeInOut, value: bookmarkManager.bookmarkedServices)
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
        .onAppear {
            // Listen for bookmark updates
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("BookmarkUpdated"),
                object: nil,
                queue: .main
            ) { _ in
                // Force view to refresh when bookmarks are updated
            
            }
        }
    }
}
