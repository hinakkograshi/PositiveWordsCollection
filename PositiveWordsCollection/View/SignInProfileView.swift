//
//  SignInProfileView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/25.
//

import SwiftUI
import PhotosUI

struct SignInProfileView: View {
    enum Field: Hashable {
        case name
        case bio
    }
    @FocusState private var focusedField: Field?
    @ObservedObject var viewModel: AuthenticationViewModel
    @State var selectedImage: UIImage?
    @State var selectedItem: PhotosPickerItem?
    @Environment(\.dismiss) private var dismiss
    @State var showImagePicker: Bool = false
    @State var showCreateProfileError: Bool = false
    @State private var disableButton: Bool = false
    @State private var isLoading = false

    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 20) {

                    VStack(spacing: 12) {
                        Text("プロフィール画像")
                            .font(.title2)
                            .fontWeight(.bold)
                        Image(uiImage: viewModel.selectedImage ?? UIImage(named: "noImage")!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 150))
                            .overlay {
                                RoundedRectangle(cornerRadius: 150)
                                    .stroke(Color.black, lineWidth: 3.0)
                            }
                            .contentShape(Rectangle())
                        PhotosPicker(selection: $selectedItem) {
                            Text("ライブラリから画像を選択")
                                .font(.headline)
                                .fontWeight(.bold)
                                .tint(.primary)
                                .padding()
                                .frame(width: 230, height: 50)
                                .background(.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .contentShape(Rectangle())
                        }
                    }
                    // PhotosPickerItem -> Data -> UIImageに変換
                    .onChange(of: selectedItem) {
                        Task {
                            guard let data = try? await selectedItem?.loadTransferable(type: Data.self) else { return }
                            guard let uiImage = UIImage(data: data) else { return }
                            viewModel.selectedImage = uiImage
                        }
                    }
                    VStack(alignment: .leading) {
                        Text("名前")
                            .fontWeight(.bold)
                        InputTextField(
                            inputTxet: $viewModel.displayName,
                            count: 10,
                            placeHolderText: "名前",
                            focused: $focusedField,
                            equals: .name
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 2)
                        }
                        .onChange(of: viewModel.displayName) {
                            viewModel.displayNameTotalCount = viewModel.displayName.count
                        }
                        Text("自己紹介")
                            .fontWeight(.bold)
                        ZStack(alignment: .topLeading) {
                            InputTextField(
                                inputTxet: $viewModel.bio,
                                count: 20,
                                placeHolderText: "自己紹介",
                                focused: $focusedField,
                                equals: .bio
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black, lineWidth: 2)
                            }
                            .onChange(of: viewModel.bio) {
                                viewModel.bioTotalCount = viewModel.bio.count
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
                .padding()
                .onChange(of: focusedField) {
                    _ = print("⭐️SignIn: \($0)")
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            if viewModel.selectedImage != UIImage(named: "noImage")!, viewModel.displayName != "" {
                                disableButton = true
                                Task {
                                    isLoading = true
                                    do {
                                        try await viewModel.createProfile()
                                        dismiss()
                                    } catch {
                                        print("createProfile Error:\(error)")
                                    }
                                    isLoading = false
                                }
                            } else {
                                showCreateProfileError = true
                            }
                        }, label: {
                            Text("登録")
                                .font(.headline)
                                .fontWeight(.bold)
                                .tint(.primary)
                                .padding(30)
                                .contentShape(Rectangle())
                        })
                        .disabled(disablePostButton())
                    }
                }
            }
            .onTapGesture {
                focusedField = nil
            }
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(20)
                    .tint(Color.white)
                    .background(Color.gray)
                    .cornerRadius(8)
                    .scaleEffect(1.6)
            }
        }
        .alert(isPresented: $showCreateProfileError) {
            Alert(title: Text("ユーザーの画像と名前を入力する必要があります。"))
        }
    }

    var isRegistrationButtonDisabled: Bool {
        viewModel.selectedImage != nil && viewModel.displayName != ""
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
    @Previewable @State var selectedImage = UIImage(named: "hiyoko")!
    return SignInProfileView(viewModel: AuthenticationViewModel())
}
