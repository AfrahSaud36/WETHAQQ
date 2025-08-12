import SwiftUI

struct LanguageSettingsView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "en"
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.layoutDirection) private var layoutDirection
    
    let languages = [
        ("English", "en", "globe"),
        ("العربية", "ar", "globe")
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(languages, id: \.1) { language in
                        LanguageRow(
                            title: language.0,
                            icon: language.2,
                            isSelected: selectedLanguage == language.1
                        ) {
                            selectedLanguage = language.1
                            // If you need RTL/LTR changes, you'd handle that here
                        }
                    }
                }
                .listRowBackground(Color(.systemBackground))
            }
            .background(Color.customBackground)
            .navigationTitle("Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.backward")
                        }
                        .foregroundColor(.customButtonColor)
                    }
                }
            }
        }        .navigationBarHidden(true)

        .navigationViewStyle(.stack)
    }
}

struct LanguageRow: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(.customButtonColor)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.customButtonColor)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct LanguageSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LanguageSettingsView()
                .environment(\.locale, .init(identifier: "en"))
            
            LanguageSettingsView()
                .environment(\.locale, .init(identifier: "ar"))
                .environment(\.layoutDirection, .rightToLeft)
        }
    }
}
