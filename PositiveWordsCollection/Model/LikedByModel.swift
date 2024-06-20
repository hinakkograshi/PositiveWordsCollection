//
//  LikedByModel.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/06/19.
//

import Foundation

struct LikedByModel: Identifiable, Hashable {
    var id = UUID() // identifiableに準拠させるためにすべてのポストモデルアイテムが固有のIDを設定
    var userID: String // データベース内のユーザーのID
//    var username: String // ユーザーとデータベースのユーザー名
    var likeCount: Int
    var dateCreated: Date // 投稿が作成された日付
    var likedByUser: Bool // ユーザーに気に入られているか
    // MARK: HashTable完成
    // この関数でIDとハッシュを持つことで、識別が可能
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
