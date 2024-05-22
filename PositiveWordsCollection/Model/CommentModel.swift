//
//  CommentModel.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/22.
//

import Foundation

struct CommentModel: Identifiable, Hashable {

    var id = UUID() // 設定
    var commentID: String // データベース内のコメントのID
    var userID: String // データベース内のユーザーのID
    var username: String // ユーザーとデータベースのユーザー名
    var content: String // コメント内容
    var dateCreated: Date // 投稿が作成された日付

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
