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
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 75))
                        .overlay {
                            RoundedRectangle(cornerRadius: 75)
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
                    TextField("名前", text: $editProfileName)
                        .textFieldStyle(.roundedBorder)
                }
                Divider()
                HStack {
                    Text("自己紹介")
                        .fontWeight(.bold)
                        .padding()
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $editProfileBio)
                            .frame(height: 100)
                            .border(Color.black)
                        if editProfileBio.isEmpty {
                            Text("自己紹介").foregroundStyle(Color(uiColor: .placeholderText))
                                .padding(8)
                                .allowsHitTesting(false)
                        }
                    }
                }
                Divider()
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
                            await saveEditProfile()
                            print("処理終わったよ！")
                            
                            print("saveされました！")
                            
                            dismiss()
                            print("閉じました")
                        }
//                        if userImage != selectedImage {
//                            saveImage {
//                                dismiss()
//                            }
//                        }
                    }, label: {
                        Text("保存")
                            .tint(.primary)
                    })
                }
            }
        }
        .onAppear {
            editProfileName = currentUserName!
            editProfileBio = currentBio!
            selectedImage = userImage
        }
    }
    // MARK: FUNCTION
//    func saveImage(completionHandler: @escaping () -> Void) {
//        print("🟩 1")
//        guard let userID = currentUserID else { return }
//        // Update UI profile image
//        self.userImage = selectedImage
//        print("🟩 2")
//        // Update profile image in database
//        Task {
//            do {
//                try await ImageManager.instance.uploadProfileImage(userID: userID, image: selectedImage)
//                print("🟩 3")
//                completionHandler()
//            } catch {
//                print("uploadProfileImage Error")
//            }
//        }
//        print("🟩 4")
//    }

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
    @State var tes = "Hinakkoです。よろしく！"
    @State var image = UIImage(named: "loading")!
    return EditProfileView(userDisplayName: $tes, userBio: $tes, userImage: $image)
}
