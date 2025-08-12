import SwiftUI

struct PriceSlider: View {
    @Binding var maxPrice: Double
    let range: ClosedRange<Double> = 0...10000 // Maximum price range
    
    private let trackHeight: CGFloat = 6
    private let knobSize: CGFloat = 28
    
    var body: some View {
        VStack(spacing: 25) {
            // Price display
            Text("Maximum Price: \(Int(maxPrice)) SR")
                .font(.headline)
                .padding(.horizontal)
            
            // Slider
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: trackHeight)
                    
                    // Selected range
                    Capsule()
                        .fill(Color.customButtonColor)
                        .frame(width: (maxPrice - range.lowerBound) / (range.upperBound - range.lowerBound) * geometry.size.width,
                               height: trackHeight)
                    
                    // Price knob
                    Circle()
                        .fill(Color.white)
                        .shadow(radius: 2)
                        .frame(width: knobSize, height: knobSize)
                        .offset(x: (maxPrice - range.lowerBound) / (range.upperBound - range.lowerBound) * (geometry.size.width - knobSize))
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { gesture in
                                    let ratio = gesture.location.x / (geometry.size.width - knobSize)
                                    let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * ratio
                                    maxPrice = max(0, min(range.upperBound, newValue))
                                }
                        )
                }
            }
            .frame(height: knobSize)
            
            // Price range labels
            HStack {
                Text("0 SR")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("10,000 SR")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
    }
}

struct PriceSortView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var maxPrice: Double
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Sort by ")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                Text("Show services up to selected price")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                PriceSlider(maxPrice: $maxPrice)
                    .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Apply ")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.customButtonColor)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarItems(
                leading: Button("Reset") {
                    maxPrice = 10000
                },
                trailing: Button("Cancel") {
                    dismiss()
                }
            )

        }
    }
} 



