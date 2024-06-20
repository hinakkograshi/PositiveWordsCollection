//
//  CommentsView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/22.
//

import SwiftUI

struct CommentsView: View {
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
                PostView(post: post, posts: PostArrayObject(), headerIsActive: false, deletedDataState: .noLoading, comentIsActive: true)
                LazyVStack {
                    ForEach(commentArray, id: \.self) { comment in
                        MessageView(comment: comment)
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
        // Update the local data
        let updatePost = PostModel(postID: post.postID, userID: post.userID, username: post.username, caption: post.caption, dateCreated: post.dateCreated, likeCount: post.likeCount, likedByUser: post.likedByUser, comentsCount: post.comentsCount + 1)
        self.post = updatePost
    }
    func addComment() {
        guard let userID = currentUserID, let userName = currentUserName else { return }
        Task {
            do {
                let returnedCommentID = try await DataService.instance.uploadComment(postID: post.postID, content: submissionText, displayName: userName, userID: userID)
                guard let commentID = returnedCommentID else { return }
                let newComment = CommentModel(commentID: commentID, userID: userID, username: userName, content: submissionText, dateCreated: Date())
                self.submissionText = ""
                self.commentArray.append(newComment)
            } catch {
                print("Upload Comment Error")
            }
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

        CommentsView(commentArray: count, post: $post)
    }
}
