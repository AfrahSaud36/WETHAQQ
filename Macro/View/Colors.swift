import SwiftUI

extension Color {
    // Primary Colors
    static let customButtonColor = Color(red: 75/255, green: 118/255, blue: 178/255) // Main blue color
    static let customBackground = Color(red: 242/255, green: 242/255, blue: 247/255) // Light gray background
    
    // Text Colors
    static let primaryText = Color.black
    static let secondaryText = Color(red: 142/255, green: 142/255, blue: 147/255) // Gray text
    static let accentText = Color(red: 75/255, green: 118/255, blue: 178/255) // Blue text
    
    // Card Colors
    static let cardBackground = Color.white
    static let cardShadow = Color.black.opacity(0.1)
    
    // Button Colors
    static let buttonBackground = Color(red: 75/255, green: 118/255, blue: 178/255)
    static let buttonText = Color.white
    
    // Form Colors
    static let formBackground = Color.white
    static let formBorder = Color(red: 199/255, green: 199/255, blue: 204/255)
    
    // Status Colors
    static let success = Color(red: 52/255, green: 199/255, blue: 89/255)
    static let error = Color(red: 255/255, green: 59/255, blue: 48/255)
    static let warning = Color(red: 255/255, green: 204/255, blue: 0/255)
    
    // Additional UI Colors
    static let separator = Color(red: 199/255, green: 199/255, blue: 204/255)
    static let placeholder = Color(red: 142/255, green: 142/255, blue: 147/255)
}
