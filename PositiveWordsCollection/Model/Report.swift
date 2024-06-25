//
//  Report.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/06/24.
//

import Foundation

struct Report: Codable {
    var postId: String
    var dateCreated: Date

    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case dateCreated = "date_created"
    }
    init(postId: String, dateCreated: Date) {
        self.postId = postId
        self.dateCreated = dateCreated
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postId = try container.decode(String.self, forKey: .postId)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
}
