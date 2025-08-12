
import SwiftUI
import PhotosUI

struct PersonalInfoView: View {
    @StateObject private var vm = PersonalInfoViewModel()
    @Environment(\.presentationMode) var presentationMode

    @State private var isEditing = false
    @State private var editedName = ""
    @State private var editedEmail = ""
    @State private var editedPhoneNumber = "" // ✅ جديد
    @State private var editedBio = ""
    // for image
    @State private var selectedItem: PhotosPickerItem?
    @State private var localImage: UIImage? = nil

    var body: some View {
        ZStack {
            Color.customBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 32) {
                    // صورة واسم المستخدم
                    HStack(spacing: 24) {
                        if isEditing {
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                if let image = localImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .onChange(of: selectedItem) {
                                guard let selectedItem else { return }
                                Task {
                                    if let data = try? await selectedItem.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        await MainActor.run {
                                            vm.profileImage = uiImage
                                            localImage = uiImage
                                        }
                                    }
                                }
                            }
                        } else {
                            if let image = vm.profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            }
                        }

                        if isEditing {
                            TextField("Name", text: $editedName)
                                .font(.title2.bold())
                                .foregroundColor(.black)
                        } else {
                            Text(!vm.name.isEmpty ? vm.name : "Name")
                                .font(.title2)
                                .foregroundColor(!vm.name.isEmpty ? .black : .gray)
                                .bold()
                        }
                        Spacer()
                    }
                    .padding(.horizontal)

                    // قسم المعلومات الشخصية
                    HStack {
                        Text("Personal Information")
                            .font(.headline)
                        Spacer()
                        Button(isEditing ? "Cancel" : "Edit") {
                            if isEditing {
                                editedName = vm.name
                                editedEmail = vm.email
                                editedPhoneNumber = vm.phoneNumber // ✅
                                editedBio = vm.bio
                                localImage = vm.profileImage
                            } else {
                                editedName = vm.name
                                editedEmail = vm.email
                                editedPhoneNumber = vm.phoneNumber // ✅
                                editedBio = vm.bio
                                localImage = vm.profileImage
                            }
                            isEditing.toggle()
                        }
                        .foregroundColor(.customButtonColor)
                        .fontWeight(.semibold)
                        .font(.subheadline)
                    }
                    .padding(.horizontal)

                    // بطاقة المعلومات
                    VStack(spacing: 0) {
                        infoRow(title: "Email", value: vm.email, isEditing: isEditing, boundText: $editedEmail)
                        Divider()
                        infoRow(title: "Phone", value: vm.phoneNumber, isEditing: isEditing, boundText: $editedPhoneNumber) // ✅ جديد
                        Divider()
                        infoRow(title: "Bio", value: vm.bio, isEditing: isEditing, boundText: $editedBio)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .gray.opacity(0.1), radius: 8, x: 0, y: 2)
                    .padding(.horizontal)

                    // زر الحفظ
                    
                    // زر الحفظ
                    if isEditing {
                        Button(action: {
                            vm.name = editedName
                            vm.email = editedEmail
                            vm.phoneNumber = editedPhoneNumber // ✅ جديد
                            vm.bio = editedBio
                            Task {
                                if await vm.checkiCloudStatus() {
                                    await vm.saveProfile()
                                    isEditing = false
                                }
                            }
                        }) {
                            Text("Save")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(editedName.isEmpty || editedEmail.isEmpty ? Color.gray : Color.customButtonColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                        .contentShape(Rectangle()) // هذه السطر يوسع منطقة اللمس
                        .disabled(editedName.isEmpty || editedEmail.isEmpty)
                    }
                    
                    
                    
//                    if isEditing {
//                        Button("Save") {
//                            vm.name = editedName
//                            vm.email = editedEmail
//                            vm.phoneNumber = editedPhoneNumber // ✅ جديد
//                            vm.bio = editedBio
//                            Task {
//                                if await vm.checkiCloudStatus() {
//                                    await vm.saveProfile()
//                                    isEditing = false
//                                }
//                            }
//                        }
//                        .fontWeight(.bold)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(editedName.isEmpty || editedEmail.isEmpty ? Color.gray : Color.customButtonColor)
//                        .foregroundColor(.white)
//                        .cornerRadius(12)
//                        .padding(.horizontal)
//                        .disabled(editedName.isEmpty || editedEmail.isEmpty)
//                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGray6))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
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
        .onAppear {
            Task {
                await vm.fetchProfile()
                DispatchQueue.main.async {
                    editedName = vm.name
                    editedEmail = vm.email
                    editedPhoneNumber = vm.phoneNumber // ✅ جديد
                    editedBio = vm.bio.isEmpty ? "iOS Developer | SwiftUI & UIKit Expert | Creating Online Courses for Mobile Development | 3+ Years Experience" : vm.bio
                }
            }
            localImage = vm.profileImage
        }
    }

    // دالة عرض صف معلومات
    @ViewBuilder
    private func infoRow(title: String, value: String, isEditing: Bool, boundText: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .bold()
            if isEditing {
                if title == "Bio" {
                    TextEditor(text: boundText)
                        .foregroundColor(.black)
                        .font(.subheadline)
                        .frame(minHeight: 100)
                        .overlay(
                            boundText.wrappedValue.isEmpty ?
                            Text("iOS Developer | SwiftUI & UIKit Expert | Creating Online Courses for Mobile Development | 3+ Years Experience")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                            : nil,
                            alignment: .topLeading
                        )
                } else {
                    TextField("", text: boundText)
                        .foregroundColor(.black)
                        .font(.subheadline)
                        .placeholder(when: boundText.wrappedValue.isEmpty) {
                            Text(title == "Email" ? "example@email.com" :
                                 title == "Phone" ? "05xxxxxxxx" : "")
                                .foregroundColor(.gray)
                        }
                }
            } else {
                Text(!value.isEmpty ? value :
                     (title == "Email" ? "example@email.com" :
                      title == "Phone" ? "05xxxxxxxx" :
                      "iOS Developer | SwiftUI & UIKit Expert | Creating Online Courses for Mobile Development | 3+ Years Experience"))
                .font(.subheadline)
                .foregroundColor(!value.isEmpty ? .black : .gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}

#Preview {
    PersonalInfoView()
}
