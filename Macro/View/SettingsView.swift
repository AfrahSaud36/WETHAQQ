import SwiftUI

struct SettingsView: View {
    @StateObject private var vm = PersonalInfoViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var isInRootView = true
    
    var body: some View {
        ZStack {
            Color.customBackground.ignoresSafeArea()
            
            NavigationView {
                VStack(spacing: 32) {
                    
                    // Profile section
                    NavigationLink(destination:   PersonalInfoView()) {
                        
                    HStack {
                            if let image = vm.profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                                    .clipShape(Circle())
                            }
                            
                            VStack(alignment: .leading) {
                                // ✅ عرض الاسم من ViewModel بدل النص الثابت
                                Text(!vm.name.isEmpty ? vm.name : "Name")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                // ✅ عرض الإيميل من ViewModel بدل النص الثابت
                                Text(!vm.email.isEmpty ? vm.email : "example@email.com")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    
                    VStack(spacing: 16) {
                        // My post section - تعديل هنا للانتقال إلى MyPostView
                        NavigationLink(destination: MyPostView()) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.customButtonColor)
                                Text("My Post")
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                        }
                        
                        // Language section
                        NavigationLink(destination: LanguageSettingsView ()) {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.customButtonColor)
                                Text("Language")
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        
                        Spacer()
                        NavigationLink(destination: TermsAndConditionsView()) {

                            HStack {

                                Text("Privacy Policy")
                                    .foregroundColor(.customButtonColor)
                            }
                         //   .padding(.top ,400)
                            
                        } }
                    Spacer()
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .onAppear {
                    isInRootView = true // عند العودة، نظهر زر الرجوع مرة أخرى

                    Task {
                        await vm.fetchProfile()
                    }
                }
                .toolbar {
                                    if isInRootView {
                                        ToolbarItem(placement: .navigationBarLeading) {
                                            Button(action: {
                                                presentationMode.wrappedValue.dismiss()
                                            }) {
                                                Image(systemName: "chevron.left")
                                                .foregroundColor(.customButtonColor)
                                            }
                                        }
                                    }
                                }
                            }    .navigationBarBackButtonHidden(true)
            
            
        }
    }}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}


