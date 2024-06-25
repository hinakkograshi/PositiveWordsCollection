//
//  Post.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/06/24.
//

import Foundation

struct Post: Codable {
    var postId: String
    var userId: String
    var displayName: String
    var caption: String
    var dateCreated: Date

    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case userId = "user_id"
        case displayName = "display_name"
        case caption = "caption"
        case dateCreated = "date_created"
    }

    init(postId: String, userId: String, displayName: String, caption: String, dateCreated: Date) {
        self.postId = postId
        self.userId = userId
        self.displayName = displayName
        self.caption = caption
        self.dateCreated = dateCreated
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postId = try container.decode(String.self, forKey: .postId)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.displayName = try container.decode(String.self, forKey: .displayName)
        self.caption = try container.decode(String.self, forKey: .caption)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
}
