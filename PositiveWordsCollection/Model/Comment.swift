//
//  Comment.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/06/24.
//

import Foundation

struct Comment: Codable {
    var commentId: String
    var userId: String
    var displayName: String
    var content: String
    var dateCreated: Date

    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case userId = "user_id"
        case displayName = "display_name"
        case content = "content"
        case dateCreated = "date_created"
    }

    init(commentId: String, userId: String, displayName: String, content: String, dateCreated: Date) {
        self.commentId = commentId
        self.userId = userId
        self.displayName = displayName
        self.content = content
        self.dateCreated = dateCreated
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.commentId = try container.decode(String.self, forKey: .commentId)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.displayName = try container.decode(String.self, forKey: .displayName)
        self.content = try container.decode(String.self, forKey: .content)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
}
