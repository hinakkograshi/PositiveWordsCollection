//
//  SignInProfileView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/25.
//

import SwiftUI

struct SignInProfileView: View {
    enum Field: Hashable {
        case name
        case bio
    }
    @FocusState private var focusedField: Field?
    @ObservedObject var viewModel: AuthenticationViewModel
    @State var selectedImage: UIImage = UIImage(named: "noImage")!
    @State var sourceType: UIImagePickerController.SourceType = UIImagePickerController.SourceType.photoLibrary
    @Environment(\.dismiss) private var dismiss
    @State var showImagePicker: Bool = false
    var body: some View {
        NavigationStack {
                VStack(spacing: 20) {
                    Text("プロフィール画像")
                        .font(.title2)
                        .fontWeight(.bold)
                    Button(action: {
                        showImagePicker.toggle()
                    }, label: {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
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
                            .font(.headline)
                            .fontWeight(.bold)
                            .tint(.primary)
                            .padding()
                            .frame(width: 230, height: 50)
                            .background(Color.MyTheme.yellowColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    })
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(imageSelection: $selectedImage, sourceType: $sourceType)
                    }
                    VStack(alignment: .leading) {
                        Text("名前")
                            .fontWeight(.bold)
                        TextField("名前", text: $viewModel.displayName)
                            .padding(10)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.orange, lineWidth: 2)
                            }
                            .focused($focusedField, equals: .name)
                            .onTapGesture {
                                focusedField = .name
                            }
                    }
                    VStack(alignment: .leading) {
                        Text("自己紹介")
                            .fontWeight(.bold)
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $viewModel.bio)
                                .frame(height: 100)
                                .padding(5)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.orange, lineWidth: 2)
                                }
                                .focused($focusedField, equals: .bio)
                                .onTapGesture {
                                    focusedField = .bio
                                }
                            if viewModel.bio.isEmpty {
                                Text("自己紹介").foregroundStyle(Color(uiColor: .placeholderText))
                                    .padding(8)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        createProfile()
                        dismiss()
                    }, label: {
                        Text("登録")
                            .font(.headline)
                            .fontWeight(.bold)
                            .tint(.primary)
                    })
                }
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }
    // MARK: Function
    func createProfile() {
        print("Create profile now")
        Task {
            do {
                let returnedID = try await AuthService.instance.createNewUserInDatabase(name: viewModel.displayName, email: viewModel.email, providerID: viewModel.providerID, provider: viewModel.provider, profileImage: selectedImage, bio: viewModel.bio)
                guard let userID = returnedID else {
                    print("returnedID nil")
                    return
                }
                print("createProfile Success")
                // 🟥logInUserToApp
                try await AuthService.instance.logInUserToApp(userID: userID)
            } catch {
                print("createProfile Error\(error)")
                throw AsyncError(message: "createProfile Error")
            }
        }
    }
}
#Preview {
    @State var selectedImage = UIImage(named: "hiyoko")!
    return SignInProfileView(viewModel: AuthenticationViewModel(), selectedImage: selectedImage)
}
