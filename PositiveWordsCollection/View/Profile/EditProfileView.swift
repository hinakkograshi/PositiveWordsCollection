//
//  EditProfileView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/24.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    enum Field: Hashable {
        case name
        case bio
    }
    @FocusState private var focusedField: Field?
    @Binding var userDisplayName: String
    @State var userBio: String
    @Binding var userImage: UIImage
    @AppStorage(CurrentUserDefaults.displayName) var currentUserName: String?
    @AppStorage(CurrentUserDefaults.bio) var currentBio: String?
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @State var editProfileName = ""
    @State var editProfileBio = ""
    @State var selectedImage: UIImage?
    @State var selectedItem: PhotosPickerItem?
    //    @State var showImagePicker: Bool = false
    @State var showEditProfileError = false
    @Environment(\.dismiss) private var dismiss
    @State private var disableButton: Bool = false
    @State var editProfileNameTotalCount = 0
    @State var editProfileBioTotalCount = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                PhotosPicker(selection: $selectedItem) {
                    Image(uiImage: selectedImage ?? UIImage(named: "loading")!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 150))
                        .overlay {
                            RoundedRectangle(cornerRadius: 150)
                                .stroke(Color.black, lineWidth: 3.0)
                        }
                }
                PhotosPicker(selection: $selectedItem) {
                    Text("ライブラリから画像を選択")
                        .font(.headline)
                        .fontWeight(.bold)
                        .tint(.primary)
                        .padding()
                        .frame(width: 230, height: 50)
                        .background(.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                // PhotosPickerItem -> Data -> UIImageに変換
                .onChange(of: selectedItem) {
                    Task {
                        guard let data = try? await selectedItem?.loadTransferable(type: Data.self) else { return }
                        guard let uiImage = UIImage(data: data) else { return }
                        selectedImage = uiImage
                    }
                }
                .padding(.vertical, 10)
                Divider()
                VStack {
                    HStack {
                        Text("名前")
                            .fontWeight(.bold)
                            .padding()
                            .padding(.trailing, 30)
                        TextField("名前(10文字以内)", text: $editProfileName)
                            .padding(10)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 2)
                            }
                            .focused($focusedField, equals: .name)
                    }
                    HStack {
                        Spacer()
                        // 入力文字数の表示
                        Text(" \(editProfileNameTotalCount) / 10")
                    }
                    .onChange(of: editProfileName) {
                        editProfileNameTotalCount = editProfileName.count
                    }
                    // 10文字以上の時最後の文字を削除制限
                    .onChange(of: editProfileName) {
                        if editProfileName.count > 10 {
                            editProfileName.removeLast(editProfileName.count - 10)
                        }
                    }
                }
                .padding(.trailing, 10)
                Divider()
                VStack {
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
                                        .stroke(Color.black, lineWidth: 2)
                                }
                                .focused($focusedField, equals: .bio)
                            if editProfileBio.isEmpty {
                                Text("自己紹介(20文字以内)").foregroundStyle(Color(uiColor: .placeholderText))
                                    .padding(8)
                            }
                        }
                    }
                    HStack {
                        Spacer()
                        // 入力文字数の表示
                        Text(" \(editProfileBioTotalCount) / 20")
                    }
                    .onChange(of: editProfileBio) {
                        editProfileBioTotalCount = editProfileBio.count
                    }
                    // 10文字以上の時最後の文字を削除制限
                    .onChange(of: editProfileBio) {
                        if editProfileBio.count > 20 {
                            editProfileBio.removeLast(editProfileBio.count - 20)
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
                        disableButton = true
                        Task {
                            await saveEditProfile()
                            dismiss()
                        }
                    }, label: {
                        Text("保存")
                            .tint(.primary)
                    })
                    .disabled(disableEditButton())
                }
            }
        }
        .alert(isPresented: $showEditProfileError) {
            Alert(title: Text("名前は空にできません。"))
        }
        .onTapGesture {
            focusedField = nil
        }
        .onAppear {
            guard let userName = currentUserName else { return }
            guard let userBio = currentBio else { return }
            editProfileName = userName
            editProfileBio = userBio
            selectedImage = userImage
        }
    }

    var isSaveButtonDisabled: Bool {
        selectedImage != UIImage(named: "noImage")! && editProfileName != ""
    }

    private func disableEditButton() -> Bool {
        var isDisabled = false
        if !isSaveButtonDisabled || disableButton == true {
            isDisabled = true
        }
        return isDisabled
    }

    private func saveEditProfile() async {
        guard let userID = currentUserID else { return }
        // Update UI
        userDisplayName = editProfileName
        userBio = editProfileBio
        guard let selectedImage = selectedImage else { return }
        userImage = selectedImage
        // Update  UserDefault
        UserDefaults.standard.setValue(editProfileName, forKey: CurrentUserDefaults.displayName)
        UserDefaults.standard.setValue(editProfileBio, forKey: CurrentUserDefaults.bio)
        // Update all of user's posts Change
        do {
            try await AuthService.instance.updateUserProfileText(userID: userID, displayName: editProfileName, bio: editProfileBio)
            try await DataService.instance.updateDisplayNameOnPosts(userID: userID, displayName: editProfileName)
            try await ImageManager.instance.uploadProfileImage(userID: userID, image: selectedImage)
            print("全て保存しました\(userID)🐥")
        } catch {
            print("Update UserName ERROR")
        }
    }
}

#Preview {
    @Previewable @State var name = "Hinakkoです。よろしく"
    @Previewable @State var image = UIImage(named: "hiyoko") ?? UIImage()
    return EditProfileView(userDisplayName: $name, userBio: name, userImage: $image)
}
