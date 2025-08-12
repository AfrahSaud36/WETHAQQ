
import SwiftUI
struct PostCard: View {
    var image: UIImage?
    var title: String
    var author: String
    var price: String
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                if let image = image {
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
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.customButtonColor)
                    Text(author)
                        .font(.headline)
                        //.fontWeight(.medium)
                        .foregroundColor(.black)
                }
            }
            Spacer()
            Text(price)
                .fontWeight(.medium)
                .padding(.top, 55)
                .font(.system(size: 13))
                .foregroundColor(.black)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
    }
}
