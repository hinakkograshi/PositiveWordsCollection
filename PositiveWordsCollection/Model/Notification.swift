//
//  File.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/09/14.
//

import Foundation

enum NotificationType: Int {
    case like = 0
    case reply = 1
}
// myUserId
// 配列:通知Id:自動
struct Notification: Codable, Equatable {
    var notificationId: String
    var postId: String
    var userId: String
    var userName: String
    var dateCreated: Date
    var type: Int

    enum CodingKeys: String, CodingKey {
        case notificationId = "notification_id"
        case postId = "post_id"
        case userId = "user_id"
        case userName = "user_name"
        case dateCreated = "date_created"
        case type = "type"
    }

    // イニシャライザ
    init(notificationId: String, postId: String, userId: String, userName: String, dateCreated: Date, type: Int) {
        self.notificationId = notificationId
        self.postId = postId
        self.userId = userId
        self.userName = userName
        self.dateCreated = dateCreated
        self.type = type
    }

    // Codableのためのデコーダ
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.notificationId = try container.decode(String.self, forKey: .notificationId)
        self.postId = try container.decode(String.self, forKey: .postId)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.userName = try container.decode(String.self, forKey: .userName)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.type = try container.decode(Int.self, forKey: .type)
    }
}

extension Notification: Identifiable {
    var id: String {
        notificationId
    }
}
