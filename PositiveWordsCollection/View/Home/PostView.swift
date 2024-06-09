//
//  PostCell.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/21.
//

import SwiftUI

struct PostView: View {
//    @StateObject var viewModel = PostViewModel(userID: <#String#>, postID: <#String#>)
    @State var post: PostModel
    @State var animateLike: Bool = false
    @State var profileImage = UIImage(named: "loading")!
    @State var postImage = UIImage(named: "loading")!
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @State var showReportsAlert: Bool = false
    @State var showDeleteAlert: Bool = false


    var body: some View {
        VStack {
            // header
            HStack {
                NavigationLink(destination: {
                    LazyView {
                        ProfileView(isMyProfile: false, profileDisplayName: post.username, profileUserID: post.userID)
                    }
                }, label: {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 60))
                        .padding(.leading, 10)
                    Text(post.username)
                        .font(.title2)
                        .fontWeight(.medium)
                        .tint(.primary)
                        .padding(.leading, 10)
                    // Time
                    Text("2s")
                        .foregroundStyle(.gray)
                        .font(.caption)
                    // light and dark mode対応
                        .foregroundStyle(.primary)
                })
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
                                Text("違反を報告する")
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
            // Content
            HStack {
                // stamp Image
                Image(uiImage: postImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100, alignment: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 10)
                // post caption
                Text(post.caption)
                    .font(.subheadline)
                    .padding(.leading, 20)
                Spacer()
            }
            .padding()

            // Footer
            HStack(alignment: .center, spacing: 5) {
                Button(action: {
                    if post.likedByUser {
                        unLikePost()
                    } else {
                        likePost()
                    }
                }, label: {
                    Image(systemName: post.likedByUser ? "heart.fill" : "heart")
                        .font(.title3)
                })
                .tint(post.likedByUser ? .red : .primary)
                Text("\(post.likeCount)")
                // MARK: Comment Icon
                HStack {
                    NavigationLink(
                        destination: CommentsView(post: $post),
                        label: {
                            Image(systemName: "bubble.middle.bottom")
                                .font(.title3)
                                .tint(.primary)
                        })
                    // 🟩Comentの数
                    Text("\(post.comentsCount)")
                    .font(.subheadline)                }
                Image(systemName: "paperplane")
                    .font(.title3)
                Spacer()
            }
            Rectangle()
                .frame(height: 1)
        }
        .alert("投稿を削除", isPresented: $showDeleteAlert, actions: {
            Button("戻る", role: .cancel) {

            }
            Button("削除", role: .destructive) {
                // Firebase削除
            }
        }, message: {
            Text("この投稿を削除しますか？")
        })
        .alert("違反を報告", isPresented: $showReportsAlert, actions: {
            Button("戻る", role: .cancel) {

            }
            Button("報告する", role: .destructive) {
                reportPost()
            }
        }, message: {
            Text("不適切な投稿を報告しますか？")
        })
        .onAppear {
                getImages()

//                .task {
//                    do {
//                        try await Task.sleep(for: .seconds(5))
//                        try await Task.sleep(for: .seconds(5))
//                        getImages()
//                    } catch {
//                        print(error)
//                    }
//                }
        }
    }
    // MARK: function
    // 報告
    func reportPost() {
        print("REPORT POST NOW")
        Task {
            do {
                try await DataService.instance.uploadReport(
                    postID: post.postID)
            } catch {
                print("REPORT POST Error")
            }
        }
    }
    // PostImage取得
    func getImages() {
        print("⭐️getImageの取得")
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
    
    func likePost() {
        guard let userID = currentUserID else {
            print("Cannot find userID while unliking post")
            return
        }
        // Update the local data
        let updatePost = PostModel(postID: post.postID, userID: post.userID, username: post.username, caption: post.caption, dateCreated: post.dateCreated, likeCount: post.likeCount + 1, likedByUser: true, comentsCount: post.comentsCount)
        self.post = updatePost
        print("postの中身\(self.post)")
        // Animate UI
        animateLike = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            animateLike = false
        }
        // Update Firebase
        DataService.instance.likePost(postID: post.postID, currentUserID: userID)
    }

    func unLikePost() {
        guard let userID = currentUserID else {
            print("Cannot find userID while unliking post")
            return
        }
        // Update the local data
        let updatePost = PostModel(postID: post.postID, userID: post.userID, username: post.username, caption: post.caption, dateCreated: post.dateCreated, likeCount: post.likeCount - 1, likedByUser: false, comentsCount: post.comentsCount)
        self.post = updatePost
        // Update Firebase
        DataService.instance.unlikePost(postID: post.postID, currentUserID: userID)
    }
    // MARK: 24.メソッド数個省略
    // X等にコピーする内容
    func sharePost() {
        let message = "Check out this post on DogGram"
        let image = postImage
        let link = URL(string: "https://www.google.com")!
        let activityViewController =  UIActivityViewController(activityItems: [message, image, link], applicationActivities: nil)
        let viewController =  UIApplication.shared.windows.first?.rootViewController
        viewController?.present(activityViewController, animated: true, completion: nil)
    }
}

//#Preview {
//    let post = PostModel(postID: "", userID: "", username: "hinakko", caption: "This is a test caption", dateCreated: Date(), likeCount: 0, likedByUser: false, comentsCount: 0)
//    return PostView(post: post)
//}
