//
//  PostModek.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/22.
//

import Foundation

struct PostModel: Identifiable, Hashable {
    var id: String 
    var postID: String // データベース内の投稿のID
    var userID: String // データベース内のユーザーのID
    var username: String // ユーザーとデータベースのユーザー名
    var caption: String // 投稿内容
    var dateCreated: Date // 投稿が作成された日付
    var likeCount: Int // いいね数
    var likedByUser: Bool // ユーザーに気に入られているか
    var comentsCount: Int // 投稿数

    // MARK: HashTable完成
    // この関数でIDとハッシュを持つことで、識別が可能
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
