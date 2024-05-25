//
//  CommentsView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/22.
//

import SwiftUI

struct CommentsView: View {
    @State var submissionText: String = ""
    @State var commentArray = [CommentModel]()
    @Binding var post: PostModel
    var body: some View {
        VStack {
            PostCell(post: post)
            ScrollView {
                LazyVStack {
                    ForEach(commentArray, id: \.self) { comment in
                        MessageView(comment: comment)

                    }

                }
            }

            HStack {
                Image("hiyoko")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                TextField("Add a commen here...", text: $submissionText)
                Button {

                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                }
                .tint(Color.MyTheme.purpleColor)
            }
            .padding(6)
        }
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: {
            getCommrnts()
        })
    }
    // MARK: FUNCTIONS
    func getCommrnts() {
        print("Get comments from DB")
        let comment1 = CommentModel(commentID: "", userID: "", username: "hinakko", content: "hello", dateCreated: Date())
        let comment2 = CommentModel(commentID: "", userID: "", username: "hina", content: "Yes", dateCreated: Date())
        let comment3 = CommentModel(commentID: "", userID: "", username: "Bob", content: "Nice", dateCreated: Date())
        let comment4 = CommentModel(commentID: "", userID: "", username: "Kevin", content: "Good", dateCreated: Date())
        commentArray.append(comment1)
        commentArray.append(comment2)
        commentArray.append(comment3)
        commentArray.append(comment4)
    }
}

#Preview {
    NavigationStack {
        @State var post = PostModel(postID: "", userID: "", username: "hinakko", caption: "This is a test caption", dateCreated: Date(), likeCount: 0, likedByUser: false)
        CommentsView(post: $post)
    }
}
