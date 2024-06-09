//
//  EditProfileView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/24.
//

import SwiftUI

struct EditProfileView: View {
    @Binding var userDisplayName: String
    @Binding var userBio: String
    @Binding var userImage: UIImage
    @AppStorage(CurrentUserDefaults.displayName) var currentUserName: String?
    @AppStorage(CurrentUserDefaults.bio) var currentBio: String?
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @State var editProfileName = ""
    @State var editProfileBio = ""
    @State var selectedImage = UIImage(named: "loading")!
    @State var sourceType: UIImagePickerController.SourceType = UIImagePickerController.SourceType.photoLibrary
    @State var showImagePicker: Bool = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    showImagePicker.toggle()
                }, label: {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 150))
                        .overlay {
                            RoundedRectangle(cornerRadius: 150)
                                .stroke(Color.orange, lineWidth: 3.0)
                        }
                })
                Button(action: {
                    showImagePicker.toggle()
                }, label: {
                    Text("ライブラリから画像を選択")
                })
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(imageSelection: $selectedImage, sourceType: $sourceType)
                }
                .padding(.bottom, 50)
                Divider()
                HStack {
                    Text("名前")
                        .fontWeight(.bold)
                        .padding()
                        .padding(.trailing, 30)
                    TextField("名前", text: $editProfileName)
                        .padding(10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.orange, lineWidth: 2)
                        }

                }
                .padding(.trailing, 10)
                Divider()
                HStack {
                    Text("自己紹介")
                        .fontWeight(.bold)
                        .padding()
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $editProfileBio)
                            .frame(height: 100)
                            .padding(5)
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.orange, lineWidth: 2)
                            }
                        if editProfileBio.isEmpty {
                            Text("自己紹介").foregroundStyle(Color(uiColor: .placeholderText))
                                .padding(8)
                                .allowsHitTesting(false)
                        }
                    }
                }
                .padding(.trailing, 10)
            }
            .navigationTitle("編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("キャンセル")
                            .tint(.primary)
                    })
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Task {
                            // キャッシュバグ解消
                            ImageManager.instance.chashRemove()
                            await saveEditProfile()
                            dismiss()
                        }
                    }, label: {
                        Text("保存")
                            .tint(.primary)
                    })
                }
            }
        }
        .onAppear {
            guard let userName = currentUserName else { return }
            guard let userBio = currentBio else { return }
            editProfileName = userName
            editProfileBio = userBio
            selectedImage = userImage
        }
    }
    // MARK: FUNCTION
    func saveEditProfile() async {
        guard let userID = currentUserID else { return }
        // Update UI
        userDisplayName = editProfileName
        userBio = editProfileBio
        userImage = selectedImage
        // Update  UserDefault
        UserDefaults.standard.setValue(editProfileName, forKey: CurrentUserDefaults.displayName)
        UserDefaults.standard.setValue(editProfileBio, forKey: CurrentUserDefaults.bio)
        // Update all of user's posts Change
            do {
                try await DataService.instance.updateDisplayNameOnPosts(userID: userID, displayName: editProfileName)
                try await AuthService.instance.updateUserProfileText(userID: userID, displayName: editProfileName, bio: editProfileBio)
                try await ImageManager.instance.uploadProfileImage(userID: userID, image: selectedImage)
                print("全て保存しました🐥")
            } catch {
                print("Update UserName ERROR")
            }
    }
}

#Preview {
    @State var name = "Hinakkoです。よろしく"
    @State var image = UIImage(named: "hiyoko") ?? UIImage()
    return EditProfileView(userDisplayName: $name, userBio: $name, userImage: $image)
}
