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
    @ObservedObject var post: PostModel
    @State var profileImage = UIImage(named: "loading")!
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @AppStorage(CurrentUserDefaults.displayName) var currentUserName: String?
    var body: some View {
        VStack {
            ScrollView {
                PostView(post: post, posts: posts, headerIsActive: false, comentIsActive: true)
                LazyVStack {
                    ForEach(commentArray, id: \.self) { comment in
                        MessageView(comment: comment, posts: posts)
                    }
                }
            }
            HStack {
                HStack(spacing: 8) {
                    // テキストフィールド
                    TextField("メッセージを入力", text: $submissionText)
                        .focused($focusedField)
                        .padding(.horizontal, 15)
                    Button {
                        if submissionText != "" {
                            addComment()
                            guard let userID = currentUserID else { return }
                            post.countComment(currentUserID: userID)
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
        .onAppear {
            getComments()
            getProfilePicture()
        }
    }
    // MARK: FUNCTIONS

    func addComment() {
        guard let userID = currentUserID, let userName = currentUserName else { return }
        Task {
            let commentID = DataService.instance.createCommentId(postID: post.postID)
            let comment = Comment(commentId: commentID, userId: userID, displayName: userName, content: submissionText, dateCreated: Date())
            await DataService.instance.uploadComment(comment: comment, postID: post.postID)
            let newComment = CommentModel(commentID: commentID, userID: userID, username: userName, content: submissionText, dateCreated: comment.dateCreated)
            // 通知
            let notificationID = NotificationService.instance.createNotificationId()
            let notification = Notification(notificationId: notificationID, postId: post.postID, userId: userID, userName: userName, dateCreated: Date(), type: 1)
            if userID != post.userID {
                await NotificationService.instance.uploadNotification(postedUserId: post.userID, notification: notification)
            }
            self.commentArray.append(newComment)
            self.submissionText = ""
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

        CommentsView(posts: PostArrayObject(), commentArray: count, post: post)
    }
}
