import SwiftUI
import CloudKit
import PhotosUI

struct AddPost: View {
    
    @State private var title = ""
    @State private var description = ""
    @State private var price = ""
    @State private var selectedServiceType = ""
    @State private var selectedContactType: String? = "Phone number"
    
    // for images
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    
    @State private var isPostAdded = false
    @Environment(\.dismiss) var dismiss

    
    let services = ["Tutoring sessions", "Test preparation", "Homework assistance", "Soft skills"]
    let contactOptions = ["Phone number", "Email"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Post Title")) {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                
                Section(header: Text("Type of Services")) {
                    Menu {
                        ForEach(services, id: \.self) { service in
                            Button(action: {
                                withAnimation(nil) {
                                    selectedServiceType = service
                                }
                            }) {
                                Text(service)
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedServiceType.isEmpty ? "" : selectedServiceType)
                                .foregroundColor(selectedServiceType.isEmpty ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.customButtonColor)
                        }
                    }
                }
                
                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section(header: Text("Price")) {
                    HStack {
                        TextField("00.0", text: $price)
                            .keyboardType(.decimalPad)
                        Text("ريال")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Add Photos")) {
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: 3 - selectedImages.count,
                        matching: .images
                    ) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add")
                        }
                        .foregroundColor(.customButtonColor)
                        .padding(6)
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                    .onChange(of: selectedItems) { oldItems, newItems in
                        Task {
                            for item in newItems {
                                if let data = try? await item.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    if selectedImages.count < 3 {
                                        selectedImages.append(uiImage)  // Directly store UIImage
                                    }
                                }
                            }
                            selectedItems.removeAll()
                        }
                    }
                    
                    if !selectedImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)  // Use UIImage here
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                            .cornerRadius(8)
                                        
                                        Button(action: {
                                            selectedImages.remove(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                        }
                                        .offset(x: 8, y: -8)
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                
                Section(header: Text("Contact")) {
                    ForEach(contactOptions, id: \.self) { option in
                        HStack {
                            Image(systemName: selectedContactType == option ? "largecircle.fill.circle" : "circle")
                                .foregroundColor(selectedContactType == option ? .customButtonColor : .gray)
                                .onTapGesture {
                                    selectedContactType = option
                                }
                            Text(option)
                        }
                    }
                }
            }
          //  .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addPostButtonTapped()
                    }
                }
            }
        }
        .tint(.customButtonColor)
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Save to CloudKit
    func addPostButtonTapped() {
        guard let priceDouble = Double(price), !title.isEmpty, !description.isEmpty else {
            print("All fields must be filled")
            return
        }
        
        // Get user record ID
        CKContainer.default().fetchUserRecordID { recordID, error in
            if let recordID = recordID {
                let userReference = CKRecord.Reference(recordID: recordID, action: .none)
                
                // Save the post to CloudKit
                let serviceTypeReference: CKRecord.Reference
                switch selectedServiceType {
                case "Test preparation":
                    serviceTypeReference = CKRecord.Reference(recordID: CKRecord.ID(recordName: "testPreparationID"), action: .none)
                case "Homework assistance":
                    serviceTypeReference = CKRecord.Reference(recordID: CKRecord.ID(recordName: "homeworkAssistanceID"), action: .none)
                case "Soft skills":
                    serviceTypeReference = CKRecord.Reference(recordID: CKRecord.ID(recordName: "softSkillsID"), action: .none)
                default:
                    serviceTypeReference = CKRecord.Reference(recordID: CKRecord.ID(recordName: "tutoringSessionsID"), action: .none)
                }
                
                savePostToCloudKit(title: title, typeOfService: serviceTypeReference, description: description, price: priceDouble, contactType: selectedContactType ?? "Phone number", userReference: userReference)
            } else {
                print("Error fetching user record ID: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func savePostToCloudKit(title: String, typeOfService: CKRecord.Reference, description: String, price: Double, contactType: String, userReference: CKRecord.Reference) {
        let postRecord = CKRecord(recordType: "post")
        postRecord["title"] = title as NSString
        postRecord["description"] = description as NSString
        postRecord["price"] = price as NSNumber
        postRecord["contact"] = contactType as NSString
        postRecord["TOS"] = typeOfService
        postRecord["user"] = userReference
        
        // Save the images as CKAssets with compression
        var imageAssets: [CKAsset] = []
        for image in selectedImages.prefix(3) {
            if let compressedImage = compressImage(image), let imageData = compressedImage.jpegData(compressionQuality: 0.8) {
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
                do {
                    try imageData.write(to: tempURL)
                    let asset = CKAsset(fileURL: tempURL)
                    imageAssets.append(asset)
                } catch {
                    print("Error saving image data: \(error)")
                }
            }
        }
        
        postRecord["images"] = imageAssets as NSArray
        
        // Save the post record to CloudKit
        let publicDatabase = CKContainer.default().publicCloudDatabase
        publicDatabase.save(postRecord) { record, error in
            if let error = error {
                print("Error saving post: \(error)")
            } else {
                print("Post saved successfully")
                DispatchQueue.main.async {
                    dismiss()
                }
            }
        }
    }
}

private func compressImage(_ image: UIImage, maxFileSizeKB: Int = 500) -> UIImage? {
    var compression: CGFloat = 1.0
    let maxFileSizeBytes = maxFileSizeKB * 1024
    
    guard var imageData = image.jpegData(compressionQuality: compression) else {
        return nil
    }
    
    // تقليل الجودة حتى الوصول إلى الحجم المطلوب
    while imageData.count > maxFileSizeBytes && compression > 0.1 {
        compression -= 0.1
        if let newData = image.jpegData(compressionQuality: compression) {
            imageData = newData
        }
    }
    
    return UIImage(data: imageData)
}

struct AddPost_Previews: PreviewProvider {
    static var previews: some View {
        AddPost()
    }
}
