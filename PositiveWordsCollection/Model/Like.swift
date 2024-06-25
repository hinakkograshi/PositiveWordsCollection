//
//  Like.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/06/24.
//

import Foundation

struct Like: Codable {
    var userId: String
    var dateCreated: Date

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case dateCreated = "date_created"
    }
    init(userId: String, dateCreated: Date) {
        self.userId = userId
        self.dateCreated = dateCreated
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
}
