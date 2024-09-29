//
//  PostModek.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/22.
//

import Foundation

class PostModel: ObservableObject, Hashable {
    @Published var postID: String // データベース内の投稿のID
    @Published var userID: String // データベース内のユーザーのID
    @Published var username: String // ユーザーとデータベースのユーザー名
    @Published var caption: String // 投稿内容
    @Published var dateCreated: Date // 投稿が作成された日付
    @Published var likeCount: Int // いいね数
    @Published var likedByUser: Bool // ユーザーに気に入られているか
    @Published var comentsCount: Int // 投稿数

    init(postID: String, userID: String, username: String, caption: String, dateCreated: Date, likeCount: Int, likedByUser: Bool, comentsCount: Int) {
        self.postID = postID
        self.userID = userID
        self.username = username
        self.caption = caption
        self.dateCreated = dateCreated
        self.likeCount = likeCount
        self.likedByUser = likedByUser
        self.comentsCount = comentsCount
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(postID)
    }

    static func == (lhs: PostModel, rhs: PostModel) -> Bool {
        lhs.postID == rhs.postID
    }

    func likePost(post: PostModel, currentUserID: String, userName: String) {
        if currentUserID != post.userID {
            // Update the local data
            likeCount += 1
            likedByUser = true
            // Update Firebase
            Task {
                do {
                    let like = Like(userId: userID, dateCreated: Date())
                    try DataService.instance.uploadLikedPost(postID: post.postID, like: like)
                    // ⭐️Update Firebase
                    DataService.instance.likePost(postID: post.postID, currentUserID: userID)
                    let notificationID = NotificationService.instance.createNotificationId()
                    let notification = Notification(notificationId: notificationID, postId: post.postID, userId: userID, userName: userName, dateCreated: Date(), type: 0)
                    if userID != post.userID {
                        await NotificationService.instance.uploadNotification(postedUserId: post.userID, notification: notification)
                    }
                } catch {
                    print("🟥Like Error")
                }
            }
        }
    }

    func unLikePost(post: PostModel, currentUserID: String) {
        if currentUserID != post.userID {
            // Update the local data
            likeCount -= 1
            likedByUser = false
            // Update Firebase
            Task {
                do {
                    try await DataService.instance.unLikePost(postID: post.postID, myUserID: currentUserID)
                    // 　⭐️Update Firebase
                    DataService.instance.unlikePost(postID: post.postID, currentUserID: currentUserID)
                } catch {
                    print("unLikePost Error")
                }
            }
        }
    }

    func countComment(currentUserID: String) {
        comentsCount += 1
        // Update Firebase
        Task {
            do {
                try await  DataService.instance.commentPostCount(postID: postID, currentUserID: currentUserID)
            } catch {
                print("Comment UpdateError")
            }
        }
    }
}

extension PostModel: Identifiable {
    var id: String {
        postID
    }
}
