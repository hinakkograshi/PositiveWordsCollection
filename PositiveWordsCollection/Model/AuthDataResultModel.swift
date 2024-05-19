//
//  AuthDataResultModel.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/18.
//

import Foundation
import FirebaseAuth

// 認証データの結果: 一瞬だけ文字列を作成する何らかのトークンを渡したい
// ローカルデータモデル
// サインイン結果が表示
struct AuthDataResultModel {
    let uid: String
    // 別の方法いらない
    let email: String?
    let photoURL: String?
// 構造体があり、別のところから初期化する
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoURL = user.photoURL?.absoluteString
    }
}
