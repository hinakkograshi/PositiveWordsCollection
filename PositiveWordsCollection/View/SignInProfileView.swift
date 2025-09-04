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
                    VStack(spacing: 20) {
                        Text("プロフィール画像")
                            .font(.title2)
                            .fontWeight(.bold)

                        PhotosPicker(selection: $selectedItem) {
                            VStack(spacing: 12) {
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
                            .submitLabel(.next)
                            .onSubmit(of: .text) {
                                focusedField = .bio
                            }
                            .focused($focusedField, equals: .name)
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
                            }
                        }
                        HStack {
                            Spacer()
                            // 入力文字数の表示
                            Text(" \(viewModel.bioTotalCount) / 20")
                        }
                    }
                    .padding(.bottom, 40)
                }
                .padding()
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
            //            .onTapGesture {
            //                focusedField = nil
            //            }
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
