//
//  SignInProfileView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/25.
//

import SwiftUI

struct SignInProfileView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @State var selectedImage: UIImage = UIImage(named: "hiyoko")!
    @State var sourceType: UIImagePickerController.SourceType = UIImagePickerController.SourceType.photoLibrary
    @Environment(\.dismiss) private var dismiss
    @State var showImagePicker: Bool = false
    var body: some View {
        NavigationStack {
            HStack {
                VStack {
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
                    })
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(imageSelection: $selectedImage, sourceType: $sourceType)
                    }
                    Divider()
                    HStack {
                        Text("名前")
                            .fontWeight(.bold)
                            .padding()
                        TextField("名前", text: $viewModel.displayName)
                            .textFieldStyle(.roundedBorder)
                    }
                    VStack(alignment: .leading) {
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $viewModel.bio)
                                .frame(height: 100)
                                .padding(5)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.blue, lineWidth: 2)
                                }
                            if viewModel.bio.isEmpty {
                                Text("自己紹介").foregroundStyle(Color(uiColor: .placeholderText))
                                    .padding(8)
                                    .allowsHitTesting(false)
                            }

                        }
                    }
                    Button {
                        createProfile()
                        dismiss()
                    } label: {
                        Text("登録")
                            .font(.headline)
                            .fontWeight(.bold)
                            .tint(.primary)
                            .padding()
                            .frame(height: 60)
                            .frame(maxWidth: .infinity)
                            .background(Color.MyTheme.yellowColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
    // MARK: Function
    func createProfile() {
        print("Create profile now")
        Task {
            do {
                try await AuthService.instance.createNewUserInDatabase(name: viewModel.displayName, email: viewModel.email, providerID: viewModel.providerID, provider: viewModel.provider, profileImage: selectedImage, bio: viewModel.bio)
                print("createProfile Success")
            } catch {
                print("createProfile Error\(error)")
            }
        }
    }
}
// #Preview {
//    @State var selectedImage = UIImage(named: "hiyoko")!
//    return SignInProfileView(viewModel: viewModel, selectedImage: selectedImage)
// }
