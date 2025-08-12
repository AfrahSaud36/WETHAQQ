import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @State private var letterIndex = -1
    @AppStorage("hasAcceptedTerms") private var hasAcceptedTerms = false
    private let text = "WETHAQ"
    
    var body: some View {
        if isActive {
            if !hasAcceptedTerms {
                TermsAndConditionsView()
            } else {
                ServicesView()
            }
        } else {
            ZStack {
                Color.customBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .scaleEffect(size)
                        .opacity(opacity)
                    
                    HStack(spacing: 2) {
                        ForEach(Array(text.enumerated()), id: \.offset) { index, letter in
                            Text(String(letter))
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(Color("blue"))
                                .opacity(index <= letterIndex ? 1 : 0)
                                .animation(.easeIn(duration: 0.6), value: letterIndex)
                        }
                    }
                }
            }
            .onAppear {
                withAnimation(.easeIn(duration: 1.2)) {
                    self.size = 0.9
                    self.opacity = 1.0
                }
                
                // Animate letters
                for index in 0..<text.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                        withAnimation {
                            letterIndex = index
                        }
                    }
                }
                
                // Navigate to next screen
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreen()
}
