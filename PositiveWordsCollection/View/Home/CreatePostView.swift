//
//  CreatePostView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/25.
//

import SwiftUI

struct CreatePostView: View {
    @FocusState private var focusedField: Bool
    @StateObject var posts: PostArrayObject
    @State var nameText = ""
    @State var bioText = ""
    @State var postStamp = UIImage(named: "noImage")!
    @State var showSelectStampView = false
    @State var selectedImage: UIImage = UIImage(named: "noImage")!
    @State var sourceType: UIImagePickerController.SourceType = UIImagePickerController.SourceType.photoLibrary
    @State var disableButton: Bool = false
    @State var showImagePicker: Bool = false
    @State var showPostContentError = false
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
                            Text("スタンプから\n画像を追加")
                                .fontWeight(.bold)
                                .tint(.primary)
                                .padding()
                                .frame(minWidth: 140, minHeight: 80)
                                .background(Color.MyTheme.yellowColor)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal)
                        }
                        Button {
                            showImagePicker = true
                        } label: {
                            Text("写真ライブラリ\nから画像を追加")
                                .fontWeight(.bold)
                                .tint(.primary)
                                .padding()
                                .frame(minWidth: 140, minHeight: 80)
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
                                .focused($focusedField)
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
                            // 2回連打で二重に投稿しないように
                            if selectedImage != UIImage(named: "noImage")!, bioText != "" {
                                disableButton = true
                                postPicture {
                                    dismiss()
                                }
                            } else {
                                showPostContentError = true
                            }
                        }, label: {
                            Text("投稿")
                                .tint(.primary)
                        })
                        .disabled(disableButton)
                    }
                }
            }
        .alert(isPresented: $showPostContentError, content: {
            return Alert(title: Text("投稿するには画像と文字を入力する必要があります。"))
        })
        .onTapGesture {
            focusedField = false
        }
            .overlay {
                if showSelectStampView == true {
                    Color.black.opacity(0.3)
                    VStack {
                        SelectStampCell(postStamp: $selectedImage, showSelectStampView: $showSelectStampView)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 400)
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
            let postID = DataService.instance.createPostId()
            let date = Date()
            let post = Post(postId: postID, userId: userID, displayName: displayName, caption: bioText, dateCreated: date)
            await DataService.instance.uploadPost(post: post, image: selectedImage)
            let postModel = PostModel(postID: postID, userID: userID, username: displayName, caption: bioText, dateCreated: date, likeCount: 0, likedByUser: false, comentsCount: 0)
            posts.dataArray.insert(postModel, at: 0)
            if posts.profileViewOn == true {
                posts.userPostArray.insert(postModel, at: 0)
            }
            completionHandler()
        }
    }
}

#Preview {
    CreatePostView(posts: PostArrayObject())
}
