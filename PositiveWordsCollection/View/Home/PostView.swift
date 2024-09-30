//
//  PostCell.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/21.
//

import SwiftUI

struct PostView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("hiddenPostIDs") var hiddenPostIDs: [String] = []
    @ObservedObject var post: PostModel
    @StateObject var posts: PostArrayObject
    @State var profileImage = UIImage(named: "loading")!
    @State var postImage = UIImage(named: "loading")!
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @AppStorage(CurrentUserDefaults.bio) var currentBio: String?
    @AppStorage(CurrentUserDefaults.displayName) var currentUserName: String?
    @State var showReportsAlert: Bool = false
    @State var showSuccessReportsAlert: Bool = false
    @State var showDeleteAlert: Bool = false
    @State private var isPostImageViewShowing = false
    let headerIsActive: Bool
    let comentIsActive: Bool

    var body: some View {
        VStack {
            // header
            HStack {
                NavigationLink(destination: {
                    if let myUserID = currentUserID, let profileBio = currentBio {
                        if post.userID == myUserID {
                            // LazyView作成
                            LazyView {
                                ProfileView(isMyProfile: true, posts: posts, profileBio: profileBio, profileDisplayName: post.username, profileUserID: post.userID)
                            }
                        } else {
                            // LazyView作成
                            LazyView {
                                ProfileView(isMyProfile: false, posts: posts, profileBio: "", profileDisplayName: post.username, profileUserID: post.userID)
                            }
                        }
                    }
                }, label: {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 60))
                        .overlay {
                            RoundedRectangle(cornerRadius: 60)
                                .stroke(Color.black, lineWidth: 1.0)
                        }
                        .padding(.leading, 10)
                    Text(post.username)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                        .padding(.leading, 10)
                })
                .disabled(headerIsActive)
                Spacer()
                Menu {
                    Button(role: .destructive) {
                        guard let userID = currentUserID else { return }
                        if post.userID == userID {
                            showDeleteAlert = true
                        } else {
                            showReportsAlert = true
                        }
                    } label: {
                        if let userID = currentUserID {
                            if post.userID == userID {
                                Text("投稿を削除する")
                            } else {
                                Text("この投稿を通報する")
                            }
                        }
                    }
                    if let userID = currentUserID {
                        if post.userID != userID {
                            Button {
                                print("⭐️隠しました")
                                hidePost()
                            } label: {
                                Text("この投稿を非表示にする")
                            }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                }

                .padding(.trailing, 10)
                .tint(.primary)
            }
            .padding(.top, 5)
            // Content
            HStack {
                Button {
                    isPostImageViewShowing = true
                } label: {
                    Image(uiImage: postImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 10)
                }
                // post caption
                Text(post.caption)
                    .font(.subheadline)
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
            // Footer
            HStack {
                Button(action: {
                    if post.likedByUser {
                        guard let userID = currentUserID else { return }
                        post.unLikePost(post: post, currentUserID: userID)
                    } else {
                        // ❤️+1
                        guard let userID = currentUserID else { return }
                        guard let userName = currentUserName else { return }
                        post.likePost(post: post, currentUserID: userID, userName: userName)
                    }
                }, label: {
                    Image(systemName: post.likedByUser ? "heart.fill" : "heart")
                        .font(.title3)
                })
                .padding(.leading, 5)
                .tint(post.likedByUser ? .red : .primary)
                Text("\(post.likeCount)")
                    .padding(.trailing, 10)
                // MARK: Comment Icon
                HStack {
                    NavigationLink(
                        destination:
                            LazyView {
                                CommentsView(posts: posts, post: post)
                            }) {
                        Image(systemName: "bubble.middle.bottom")
                            .font(.title3)
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                    }
                    .disabled(comentIsActive)
                    // 🟩Comentの数
                    Text("\(post.comentsCount)")
                        .font(.subheadline)
                }
                //                Image(systemName: "paperplane")
                //                    .font(.title3)
                Spacer()
                Text(DateManager.stringFromCreatedDate(date: post.dateCreated))
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .padding(.trailing, 10)
            }
            Rectangle()
                .frame(height: 1)
        }
        .sheet(isPresented: $isPostImageViewShowing) {
            NavigationStack {
                PostImageView(displayingPostImage: postImage)
            }
        }
        .alert("投稿を削除", isPresented: $showDeleteAlert, actions: {
            Button("戻る", role: .cancel) {

            }
            Button("削除", role: .destructive) {
                Task {
                    // 🟥削除メソッド
                    deletePostView()
                }
            }
        }, message: {
            Text("この投稿を削除しますか？")
        })
        .alert("この投稿を通報", isPresented: $showReportsAlert, actions: {
            Button("戻る", role: .cancel) {

            }
            Button("通報する", role: .destructive) {
                do {
                    try reportPost()
                } catch {
                    print("REPORT POST　Error")
                }
            }
        }, message: {
            Text("不適切な投稿を通報しますか？")
        })
        .alert("通報完了", isPresented: $showSuccessReportsAlert, actions: {
            Button("OK") {
                showSuccessReportsAlert = false
            }
        }, message: {
            Text("通報できました。")
        })
        .onAppear {
            getImages()
        }
    }

    func hidePost() {
        hiddenPostIDs.append(post.postID)
        let deletedDataArray = posts.dataArray.filter { $0 != post }
        posts.dataArray = deletedDataArray
        print("⭐️\(hiddenPostIDs)⭐️")
    }

    func deletePostView() {
        Task {
            do {
                try await DeleteService.instance.postDelete(postID: post.postID)
                let deletedDataArray = posts.dataArray.filter { $0 != post }
                posts.dataArray = deletedDataArray
                let deletedUserArray = posts.myUserPostArray.filter { $0 != post }
                posts.myUserPostArray = deletedUserArray
            } catch {
                print("投稿削除に失敗しました。")
            }
        }
    }
    // 報告
    func reportPost()  throws {
        print("REPORT POST NOW")
        Task {
            let reports = Report(postId: post.postID, dateCreated: Date())
            try DataService.instance.uploadReport(reports: reports) { success in
                if success {
                    showSuccessReportsAlert = true
                } else {
                    print("REPORT Error")
                }
            }
        }
    }
    // PostImage取得
    func getImages() {
        // Get Profile image
        ImageManager.instance.downloadProfileImage(userID: post.userID) { returnedImage in
            if let image = returnedImage {
                self.profileImage = image
            }
        }
        // Get Post image
        ImageManager.instance.downloadPostImage(postID: post.postID) { returnedImage in
            if let image = returnedImage {
                self.postImage = image
            }
        }
    }

    // X等にコピーする内容
    //    func sharePost() {
    //        let message = "Check out this post on DogGram"
    //        let image = postImage
    //        let link = URL(string: "https://www.google.com")!
    //        let activityViewController =  UIActivityViewController(activityItems: [message, image, link], applicationActivities: nil)
    //        let viewController =  UIApplication.shared.windows.first?.rootViewController
    //        viewController?.present(activityViewController, animated: true, completion: nil)
    //    }
}

#Preview {
    @State var post = PostModel(postID: "", userID: "", username: "hinakko", caption: "This is a test caption", dateCreated: Date(), likeCount: 0, likedByUser: false, comentsCount: 0)
    return PostView(post: post, posts: PostArrayObject(), headerIsActive: true, comentIsActive: false)
}
