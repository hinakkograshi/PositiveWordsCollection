//
//  CommentsView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/22.
//

import SwiftUI

struct CommentsView: View {
    @StateObject var posts: PostArrayObject
    @FocusState private var focusedField: Bool
    @State var submissionText: String = ""
    @State var commentArray = [CommentModel]()
    @Binding var post: PostModel
    @State var profileImage: UIImage = UIImage(named: "loading")!
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @AppStorage(CurrentUserDefaults.displayName) var currentUserName: String?
    var body: some View {
        VStack {
            ScrollView {
                PostView(post: post, posts: PostArrayObject(), headerIsActive: false, comentIsActive: true)
                LazyVStack {
                    ForEach(commentArray, id: \.self) { comment in
                        MessageView(comment: comment, posts: posts)
                    }
                }
            }
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        // 背景
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 239 / 255,
                                        green: 239 / 255,
                                        blue: 241 / 255))
                            .frame(height: 36)
                        // テキストフィールド
                        TextField("メッセージを入力", text: $submissionText)
                            .focused($focusedField)
                            .padding(.horizontal, 15)
                    }
                    Button {
                        if submissionText != "" {
                            addComment()
                            countComment()
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.title2)
                    }
                    .tint(.orange)
                }
                .padding(8)
            }
            .border(.gray)
        }
        .onTapGesture {
            focusedField = false
        }
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: {
            getComments()
            getProfilePicture()
        })
    }
    // MARK: FUNCTIONS
    // 🟩追加
    func countComment() {
        guard let userID = currentUserID else { return }
        // Update the local data
        let updatePost = PostModel(postID: post.postID, userID: post.userID, username: post.username, caption: post.caption, dateCreated: post.dateCreated, likeCount: post.likeCount, likedByUser: post.likedByUser, comentsCount: post.comentsCount + 1)
        self.post = updatePost
        // Update Firebase
                Task {
                    do {
                        try await  DataService.instance.commentPostCount(postID: post.postID, currentUserID: userID)
                    } catch {
                        print("Comment UpdateError")
                    }
                }
    }
    func addComment() {
        guard let userID = currentUserID, let userName = currentUserName else { return }
        Task {
                let commentID = DataService.instance.createCommentId(postID: post.postID)
                let comment = Comment(commentId: commentID, userId: userID, displayName: userName, content: submissionText, dateCreated: Date())
                await DataService.instance.uploadComment(comment: comment, postID: post.postID)
                let newComment = CommentModel(commentID: commentID, userID: userID, username: userName, content: submissionText, dateCreated: comment.dateCreated)
                self.submissionText = ""
                self.commentArray.append(newComment)
        }
    }
    func getProfilePicture() {
        guard let userID = currentUserID else { return }
        ImageManager.instance.downloadProfileImage(userID: userID) { returnedImage in
            if let image = returnedImage {
                self.profileImage = image
            }
        }
    }
    func getComments() {
        // 空の場合、コメント読み込む
        guard self.commentArray.isEmpty else { return }
        Task {
            do {
                let returnedComment = try await DataService.instance.downloadComments(postID: post.postID)
                commentArray.append(contentsOf: returnedComment)
            } catch {
                print("Comment download Error")
            }
        }
    }
}

#Preview {
    NavigationStack {
        @State var post = PostModel(postID: "", userID: "", username: "hinakko", caption: "This is a test caption", dateCreated: Date(), likeCount: 0, likedByUser: false, comentsCount: 0)
        @State var count = [CommentModel(commentID: "", userID: "", username: "", content: "HelloooooooooooooooHelloooooooooooooooHellooooooooooooooo", dateCreated: Date())]

        CommentsView(posts: PostArrayObject(), commentArray: count, post: $post)
    }
}
