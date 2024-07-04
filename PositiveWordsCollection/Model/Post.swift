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
    var likeCount: Int
    var commentCount: Int

    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case userId = "user_id"
        case displayName = "display_name"
        case caption = "caption"
        case dateCreated = "date_created"
        case likeCount = "like_count"
        case commentCount = "comment_count"
    }

    init(postId: String, userId: String, displayName: String, caption: String, dateCreated: Date, likeCount: Int, commentCount: Int) {
        self.postId = postId
        self.userId = userId
        self.displayName = displayName
        self.caption = caption
        self.dateCreated = dateCreated
        self.likeCount = likeCount
        self.commentCount = commentCount
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postId = try container.decode(String.self, forKey: .postId)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.displayName = try container.decode(String.self, forKey: .displayName)
        self.caption = try container.decode(String.self, forKey: .caption)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.likeCount = try container.decode(Int.self, forKey: .likeCount)
        self.commentCount = try container.decode(Int.self, forKey: .commentCount)
    }
}
