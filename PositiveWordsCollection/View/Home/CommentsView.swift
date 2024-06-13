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
                // 🟥 posts
                PostView(post: post, posts: PostArrayObject(), isActive: false)
                LazyVStack {
                    ForEach(commentArray, id: \.self) { comment in
                        MessageView(comment: comment)
                    }
                }
            }

            HStack {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40, alignment: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                TextField("Add a commen here...", text: $submissionText)
                    .focused($focusedField)
                Button {
                    addComment()
                    countComment()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                }
                .tint(Color.MyTheme.purpleColor)
            }
            .padding(6)
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
        // Animate UI
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
            do {
                let returnedCommentID = try await DataService.instance.uploadComment(postID: post.postID, content: submissionText, displayName: userName, userID: userID)
                guard let commentID = returnedCommentID else { return }
                let newComment = CommentModel(commentID: commentID, userID: userID, username: userName, content: submissionText, dateCreated: Date())
                self.commentArray.append(newComment)
                self.submissionText = ""
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
