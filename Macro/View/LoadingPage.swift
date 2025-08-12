import SwiftUI

struct LoadingPage: View {
    @State private var shouldNavigate = false
    @State private var opacity: Double = 1.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .opacity(opacity)
            }
            .navigationDestination(isPresented: $shouldNavigate) {
                ContentView()
            }
            .onAppear {
                // Start fade animation
                withAnimation(
                    .easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true)
                ) {
                    opacity = 0.4
                }
                
                // Navigate after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    shouldNavigate = true
                }
            }
        }
    }
}

#Preview {
    LoadingPage()
}
