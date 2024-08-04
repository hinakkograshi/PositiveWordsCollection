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
    @State var sourceType: UIImagePickerController.SourceType = UIImagePickerController.SourceType.photoLibrary
    @Environment(\.dismiss) private var dismiss
    @State var showImagePicker: Bool = false
    @State var showCreateProfileError: Bool = false
    @State private var disableButton: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("プロフィール画像")
                    .font(.title2)
                    .fontWeight(.bold)
                Button(action: {
                    showImagePicker.toggle()
                }, label: {
                    Image(uiImage: viewModel.selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 150))
                        .overlay {
                            RoundedRectangle(cornerRadius: 150)
                                .stroke(Color.black, lineWidth: 3.0)
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
                    ImagePicker(imageSelection: $viewModel.selectedImage, sourceType: $sourceType)
                }
                VStack(alignment: .leading) {
                    Text("名前")
                        .fontWeight(.bold)
                    TextField("名前(10文字以内)", text: $viewModel.displayName)
                        .padding(10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .focused($focusedField, equals: .name)
                        .onTapGesture {
                            focusedField = .name
                        }
                        .onChange(of: viewModel.displayName) {
                            viewModel.displayNameTotalCount = viewModel.displayName.count
                        }
                    // 10文字以上の時最後の文字を削除制限
                        .onChange(of: viewModel.displayName) {
                            if viewModel.displayName.count > 10 {
                                viewModel.displayName.removeLast(viewModel.displayName.count - 10)
                            }
                        }
                    HStack {
                        Spacer()
                        // 入力文字数の表示
                        Text(" \(viewModel.displayNameTotalCount) / 10")
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
                                    .stroke(Color.black, lineWidth: 2)
                            }
                            .focused($focusedField, equals: .bio)
                            .onTapGesture {
                                focusedField = .bio
                            }
                            .onChange(of: viewModel.bio) {
                                viewModel.bioTotalCount = viewModel.bio.count
                            }
                        // 20文字以上の時最後の文字を削除制限
                            .onChange(of: viewModel.bio) {
                                if viewModel.bio.count > 20 {
                                    viewModel.bio.removeLast(viewModel.bio.count - 20)
                                }
                            }
                        if viewModel.bio.isEmpty {
                            Text("自己紹介(20文字以内)").foregroundStyle(Color(uiColor: .placeholderText))
                                .padding(8)
                                .allowsHitTesting(false)
                        }
                    }
                    HStack {
                        Spacer()
                        // 入力文字数の表示
                        Text(" \(viewModel.bioTotalCount) / 20")
                    }
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if viewModel.selectedImage != UIImage(named: "noImage")!, viewModel.displayName != "" {
                            disableButton = true
                            Task {
                                do {
                                    try await viewModel.createProfile()
                                    dismiss()
                                } catch {
                                    print("createProfile Error:\(error)")
                                }
                            }
                        } else {
                            showCreateProfileError = true
                        }
                    }, label: {
                        Text("登録")
                            .font(.headline)
                            .fontWeight(.bold)
                            .tint(.primary)
                    })
                    .disabled(disablePostButton())
                }
            }
        }
        .alert(isPresented: $showCreateProfileError, content: {
            return Alert(title: Text("ユーザーの画像と名前を入力する必要があります。"))
        })
        .onTapGesture {
            focusedField = nil
        }
    }

    var isRegistrationButtonDisabled: Bool {
        viewModel.selectedImage != UIImage(named: "noImage")! && viewModel.displayName != ""
    }

    private func disablePostButton() -> Bool {
        var isDisabled = false
        if !isRegistrationButtonDisabled || disableButton == true {
            isDisabled = true
        }
        return isDisabled
    }
}
#Preview {
    @State var selectedImage = UIImage(named: "hiyoko")!
    return SignInProfileView(viewModel: AuthenticationViewModel())
}
