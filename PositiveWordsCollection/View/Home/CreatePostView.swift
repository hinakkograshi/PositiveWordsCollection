//
//  CreatePostView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/25.
//

import SwiftUI

struct CreatePostView: View {
    @State var nameText = ""
    @State var bioText = ""
    @State var postStamp = UIImage(named: "noImage")!
    @State var showSelectStampView = false
    @State var selectedImage: UIImage = UIImage(named: "noImage")!
    @State var sourceType: UIImagePickerController.SourceType = UIImagePickerController.SourceType.photoLibrary
    @State var showImagePicker: Bool = false
    @Environment(\.dismiss) private var dismiss
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @AppStorage(CurrentUserDefaults.displayName) var currentUserName: String?
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button(action: {
                        showSelectStampView = true
                    }, label: {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.orange, lineWidth: 5.0)
                            }
                    })
                    VStack {
                        Button {
                            showSelectStampView = true
                        } label: {
                            Text("オリジナルスタンプから追加")
                                .fontWeight(.bold)
                                .tint(.primary)
                                .padding()
                                .frame(height: 80)
                                .frame(maxWidth: .infinity)
                                .background(Color.MyTheme.yellowColor)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal)
                        }
                        Button {
                            showImagePicker = true
                        } label: {
                            Text("写真ライブラリから画像を追加")
                                .fontWeight(.bold)
                                .tint(.primary)
                                .padding()
                                .frame(height: 80)
                                .frame(maxWidth: .infinity)
                                .background(Color.MyTheme.yellowColor)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal)
                        }
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker(imageSelection: $selectedImage, sourceType: $sourceType)
                        }
                    }
                }
                    .padding(.vertical, 30)
                    VStack(alignment: .leading) {
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $bioText)
                                .frame(height: 200)
                                .padding(5)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.orange, lineWidth: 5.0)
                                }
                            if bioText.isEmpty {
                                Text("今日はどんな良いことがありましたか？").foregroundStyle(Color(uiColor: .placeholderText))
                                    .padding(8)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    Spacer()
                }

                .padding()
                .navigationTitle("ポスト")
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
                            postPicture {
                                dismiss()
                            }
                        }, label: {
                            Text("保存")
                                .tint(.primary)
                        })
                    }
                }
            }
            .overlay {
                if showSelectStampView == true {
                    Color.black.opacity(0.3)
                    VStack {
                        SelectStampCell(postStamp: $selectedImage, showSelectStampView: $showSelectStampView)
                    }
                    .frame(width: 300, height: 400)
                    .background()
                }
            }
    }
    // FUNCTION
    func postPicture(completionHandler: @escaping () -> Void) {
        print("Post picture to DB here")
        guard let userID = currentUserID, let displayName = currentUserName else {
            print("Error getting userOD or displayname posting image")
            return
        }
        Task {
            await DataService.instance.uploadPost(image: selectedImage, caption: bioText, displayName: displayName, userID: userID)
            completionHandler()
        }
    }
}

#Preview {
    CreatePostView()
}
