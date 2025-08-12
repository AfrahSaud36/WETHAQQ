import SwiftUI

struct TermsAndConditionsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var acceptedTerms = false
    @State private var acceptedPrivacy = false
    @AppStorage("hasAcceptedTerms") private var hasAcceptedTerms = false
    
    var body: some View {
        ZStack {
            Color.customBackground.ignoresSafeArea()
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) { // Reduced spacing from 20 to 16
                        // Header
                        headerSection
                        
                        // Main Content
                        promotedContentSection
                        userBehaviorSection
                        privacyPolicySection
                        
                        // Checkboxes
                        VStack(alignment: .leading, spacing: 12) { // Reduced spacing from 16 to 12
                            Toggle(isOn: $acceptedTerms) {
                                Text("I accept the Terms and Conditions")
                                    .foregroundColor(.primaryText)
                                    .font(.subheadline) // Added font size
                            }
                            .toggleStyle(CheckboxToggleStyle())
                            
                            Toggle(isOn: $acceptedPrivacy) {
                                Text("I accept the Privacy Policy")
                                    .foregroundColor(.primaryText)
                                    .font(.subheadline) // Added font size
                            }
                            .toggleStyle(CheckboxToggleStyle())
                        }
                        .padding(.vertical, 12) // Reduced vertical padding
                        
                        // Agree Button
                        Button(action: {
                            if acceptedTerms && acceptedPrivacy {
                                hasAcceptedTerms = true
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            Text("Agree")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50) // Fixed button height
                                .background(
                                    (acceptedTerms && acceptedPrivacy) ?
                                    Color.customButtonColor :
                                    Color.customButtonColor.opacity(0.5)
                                )
                                .cornerRadius(10)
                        }
                        .disabled(!acceptedTerms || !acceptedPrivacy)
                        .padding(.top, 8) // Reduced top padding
                        
                        // Footer
                        footerSection
                    }
                    .padding(.horizontal, 16) // Reduced horizontal padding
                    .padding(.vertical, 8) // Reduced vertical padding
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if hasAcceptedTerms {
                            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.customButtonColor)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) { // Reduced spacing
            Text("Terms & Conditions")
                .font(.headline) // Changed from largeTitle to title
                .bold()
                .padding(.bottom, 4) // Added bottom padding
            
            Text("Last Updated: \(formattedDate)")
                .font(.caption2) // Changed from footnote to caption2
                .foregroundColor(.secondary)
            
            Divider()
        }
    }
    
    private var promotedContentSection: some View {
        Section {
            SectionHeader(title: "4. Promoted Content & User Conduct")
            
            SubSectionHeader(title: "4.1 Freemium Model")
            BulletPoint(text: "Free Use: The WETHAQ app is free to download and use. All core features, including posting and searching for services, are available without charge.")
            BulletPoint(text: "Optional Promoted Posts: Users may purchase promotional upgrades (\"Promo Posts\") to increase content visibility. These are entirely optional and not required to use the app.")
            BulletPoint(text: "Payment Processing: All payments are processed through the Apple App Store. We never collect or store payment information.")
            BulletPoint(text: "Refunds: All sales are final except where required by Saudi law. Refund requests must be submitted through Apple's system.")
        }
    }
    
    private var userBehaviorSection: some View {
        Section {
            SubSectionHeader(title: "4.2 User Behavior Policy")
            
            Text("Prohibited Conduct:").sectionSubheader()
            BulletPoint(text: "Use foul, abusive, or harassing language")
            BulletPoint(text: "Post discriminatory content (based on gender, religion, ethnicity, etc.)")
            BulletPoint(text: "Misrepresent qualifications or services")
            BulletPoint(text: "Share contact information to bypass the platform")
            
            Text("Consequences:").sectionSubheader()
            BulletPoint(text: "Immediate post removal")
            BulletPoint(text: "Temporary or permanent account suspension")
            BulletPoint(text: "Forfeiture of any paid Promo Post credits")
            
            Text("Reporting:").sectionSubheader()
            BulletPoint(text: "In-app reporting tool")
        }
    }
    
    private var privacyPolicySection: some View {
        Section {
            SectionHeader(title: "Privacy Policy")
            
            SubSectionHeader(title: "3.2 Payment & Safety")
            BulletPoint(text: "Payment Data: All purchases are processed by Apple. We only receive confirmation of completed transactions.")
            BulletPoint(text: "Content Moderation: We scan all posts and messages for prohibited content using AI and human reviewers to maintain a respectful community.")
        }
    }
    
    private var footerSection: some View {
        VStack(alignment: .leading, spacing: 8) { // Reduced spacing
            Divider()
            
            Text("By using WETHAQ, you agree to these Terms & Conditions and our Privacy Policy.")
                .font(.caption) // Changed from footnote to caption
                .foregroundColor(.secondary)
        }
        .padding(.top, 8) // Added top padding
    }
    
    // MARK: - Helper Methods
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
}

// MARK: - Reusable Components

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline) // Changed from title2 to title3
            .bold()
            .padding(.top, 8) // Reduced top padding
    }
}

struct SubSectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.caption) // Changed from headline to callout
            .bold()
            .padding(.top, 6) // Reduced top padding
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 6) { // Reduced spacing
            Text("•")
            Text(text)
                .font(.caption2) // Added font size
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.leading, 8)
        .padding(.vertical, 2)
    }
}

extension Text {
    func sectionSubheader() -> some View {
        self
            .font(.footnote) // Changed from subheadline to footnote
            .bold()
            .padding(.top, 4) // Reduced top padding
            .foregroundColor(.primaryText)
    }
}

// Custom checkbox toggle style
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 20, height: 20) // Fixed size
                .foregroundColor(configuration.isOn ? .customButtonColor : .secondary)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
    }
}

// MARK: - Preview

struct TermsAndConditionsView_Previews: PreviewProvider {
    static var previews: some View {
        TermsAndConditionsView()
    }
}
