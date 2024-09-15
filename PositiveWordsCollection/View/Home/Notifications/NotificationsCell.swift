//
//  NotificationsCell.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/09/16.
//

import SwiftUI

struct NotificationsCell: View {
    let notification: Notification
    @State private var postModel: PostModel? = nil
    @AppStorage(CurrentUserDefaults.displayName) var currentUserName: String?
    @ObservedObject var posts: PostArrayObject
    @State var profileImage = UIImage(named: "loading")!
    @State private var toCommentView = false
    var body: some View {
        VStack {
            HStack {
                if let notificationType = NotificationType(rawValue: notification.type) {
                    switch notificationType {
                    case .like:
                        Image(systemName: "heart.fill")
                            .font(.title3)
                            .foregroundStyle(.red)
                    case .reply:
                        Image(systemName: "bubble.middle.bottom")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                    }
                }
                NavigationLink {
                    LazyView(content: {
                        ProfileView(isMyProfile: false, posts: posts, profileBio: "", profileDisplayName: notification.userName, profileUserID: notification.userId)
                    })
                } label: {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 60))
                        .overlay {
                            RoundedRectangle(cornerRadius: 60)
                                .stroke(Color.black, lineWidth: 1.0)
                        }
                        .padding(5)
                }
                Button {
                    Task {
                        postModel = await getPost()
                        toCommentView = true
                    }
                } label: {
                    HStack {
                        if let notificationType = NotificationType(rawValue: notification.type) {
                            switch notificationType {
                            case .like:
                                Text(notification.userName + "さんが")
                                    .font(.subheadline)
                                + Text("あなたの投稿に")
                                    .font(.subheadline)
                                + Text("いいね").fontWeight(.bold)
                                + Text("しました！")
                                    .font(.subheadline)
                            case .reply:
                                Text(notification.userName + "さんが")
                                    .font(.subheadline)
                                + Text("あなたの投稿に")
                                    .font(.subheadline)
                                + Text("返信").fontWeight(.bold)
                                + Text("しました！")
                                    .font(.subheadline)
                            }
                        }
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                }
            }
            .padding(5)
            HStack {
                Spacer()
                Text(DateManager.stringFromCreatedDate(date: notification.dateCreated))
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .padding(.trailing, 10)
            }
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.secondary)
        }
        .navigationDestination(isPresented: $toCommentView, destination: {
            if let postModel = postModel {
                LazyView(content: {
                    CommentsView(posts: posts, post: postModel)
                })
            }
        })
        .onAppear {
            getImages()
        }
    }
    func getPost() async -> PostModel? {
        guard let userName = currentUserName else { return nil }
        let post = await DataService.instance.getPost(from: notification.postId)!
        let likeByUser = await DataService.instance.likeByUserFromPostId(postId: notification.postId)
        let postModel = PostModel(postID: post.postId, userID: post.userId, username: userName, caption: post.caption, dateCreated: post.dateCreated, likeCount: post.likeCount, likedByUser: likeByUser, comentsCount: post.commentCount)
        return postModel
    }
    func getImages() {
        // Get Profile image
        ImageManager.instance.downloadProfileImage(userID: notification.userId) { returnedImage in
            if let image = returnedImage {
                self.profileImage = image
            }
        }
    }
}

#Preview {
    let notification = Notification(notificationId: "1", postId: "12", userId: "23", userName: "hinakko", dateCreated: Date(), type: 1)
    return NotificationsCell(notification: notification, posts: PostArrayObject())
}

