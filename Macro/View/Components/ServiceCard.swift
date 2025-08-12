import SwiftUI
import CloudKit

struct ServiceCard: View {
    let title: String
    let author: String
    let price: Double
    let imageAssets: [CKAsset]?
    let imageKey: String
    let onBookmarkTap: () -> Void
    let isBookmarked: Bool
    @State private var loadedImage: UIImage?
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
            // Image section
            Group {
                if let image = loadedImage {
                    Image(uiImage: image)
                        .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                        Color.gray
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                }
            }
                
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.customButtonColor)
                Text(author)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
            }
            }
            
            Spacer()
            
            VStack(alignment: .trailing,spacing: 15) {
            // Bookmark button
            Button(action: onBookmarkTap) {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .resizable()
                    .frame(width: 20, height: 24)                .foregroundColor(isBookmarked ? .blue : .gray)
                   
               
                }
                
                Text(String(format: "%.2f SR", price))
                    .fontWeight(.medium)
                    .font(.system(size: 13))
                    .foregroundColor(.black)
                    .padding(.top, 4)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
       // .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onAppear {
            loadImageFromAssets()
        }
    }
    
    private func loadImageFromAssets() {
        guard let assets = imageAssets,
              let firstAsset = assets.first,
              let fileURL = firstAsset.fileURL else {
            return
        }
        
        Task {
            do {
                let data = try Data(contentsOf: fileURL)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.loadedImage = image
                    }
                }
            } catch {
                print("Error loading image: \(error)")
            }
        }
    }
}

// Helper function to load image from CKAsset
func loadImageFromAsset(_ assets: [CKAsset]?) -> UIImage? {
    guard let assets = assets,
          let firstAsset = assets.first,
          let fileURL = firstAsset.fileURL,
          let data = try? Data(contentsOf: fileURL),
          let image = UIImage(data: data) else {
        return nil
    }
    return image
}

// Preview provider
struct ServiceCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ServiceCard(
                title: "Sample Service",
                author: "By: John Doe",
                price: 99.99,
                imageAssets: nil,
                imageKey: "",
                onBookmarkTap: {},
                isBookmarked: false
            )
            
            ServiceCard(
                title: "Another Service",
                author: "Jane Smith",
                price: 149.99,
                imageAssets: nil,
                imageKey: "",
                onBookmarkTap: {},
                isBookmarked: true
            )
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
} 
