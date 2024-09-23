//
//  PostModek.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/22.
//

import Foundation

class PostModel: Hashable {
    var postID: String // データベース内の投稿のID
    var userID: String // データベース内のユーザーのID
    var username: String // ユーザーとデータベースのユーザー名
    var caption: String // 投稿内容
    var dateCreated: Date // 投稿が作成された日付
    var likeCount: Int // いいね数
    var likedByUser: Bool // ユーザーに気に入られているか
    var comentsCount: Int // 投稿数

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
        hasher.combine(userID)
        hasher.combine(username)
        hasher.combine(caption)
        hasher.combine(dateCreated)
        hasher.combine(likeCount)
        hasher.combine(likedByUser)
        hasher.combine(comentsCount)
    }

    static func == (lhs: PostModel, rhs: PostModel) -> Bool {
        lhs.postID == rhs.postID &&
            lhs.userID == rhs.userID &&
            lhs.username == rhs.username &&
            lhs.caption == rhs.caption &&
            lhs.dateCreated == rhs.dateCreated &&
            lhs.likeCount == rhs.likeCount &&
            lhs.likedByUser == rhs.likedByUser &&
            lhs.comentsCount == rhs.comentsCount
    }
}

extension PostModel: Identifiable {
    var id: String {
        postID
    }
}
