import SwiftUI

extension Color {
    static let card11 = Color(red: 0.31, green: 0.48, blue: 0.77) // Blue color
    static let card22 = Color(red: 0.58, green: 0.44, blue: 0.86) // Purple color
}

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
