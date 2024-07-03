//
//  MessageView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/22.
//

import SwiftUI

struct MessageView: View {
    @State var comment: CommentModel
    @StateObject var posts: PostArrayObject
    @State var profileImage = UIImage(named: "loading")!
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    var body: some View {
        VStack {
            if let userID = currentUserID {
                if comment.userID == userID {
                    HStack {
                        Spacer(minLength: 0)
                        VStack(alignment: .trailing, spacing: 8, content: {
                            Text(comment.username)
                                .font(.caption)
                            BalloonText(comment.content)
                        })
                        .padding(.trailing, 5)
                    }
                } else {
                    HStack {
                        NavigationLink(destination: LazyView(content: {
                            ProfileView(isMyProfile: false, profileDisplayName: comment.username, profileUserID: comment.userID, posts: posts)
                        }), label: {
                            if let userID = currentUserID {
                                if comment.userID != userID {
                                    Image(uiImage: profileImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40, alignment: .center)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                }
                            }
                        })
                        .padding(.leading, 5)
                        VStack(alignment: .leading, spacing: 8, content: {
                            Text(comment.username)
                                .font(.caption)
                            BalloonText(comment.content, mirrored: true)
                        })
                        Spacer(minLength: 0)
                    }
                }
            }
        }
        .onAppear(perform: {
            getProfileImage()
        })
    }
    // MARK: FUNCTION
    func getProfileImage() {
        ImageManager.instance.downloadProfileImage(userID: comment.userID) { returnedImage in
            if let image = returnedImage {
                // プロフィール画像更新
                self.profileImage = image
            }
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let comment = CommentModel(commentID: "", userID: "", username: "hinakko", content: "This photo is really cool. haha", dateCreated: Date())
    @State var post = PostModel(id: "1", postID: "", userID: "", username: "hinakko", caption: "This is a test caption", dateCreated: Date(), likeCount: 0, likedByUser: false, comentsCount: 0)
    return MessageView(comment: comment, posts: PostArrayObject())
}
