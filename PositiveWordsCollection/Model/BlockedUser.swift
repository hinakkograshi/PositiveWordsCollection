//
//  BlockedUser.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/07/07.
//

import Foundation

struct BlockedUser: Codable {
    var myblockingUser: String
    var blockedUser: String

    enum CodingKeys: String, CodingKey {
        case myblockingUser = "myblocking_user"
        case blockedUser = "blocked_user"
    }
    init(myblockingUser: String, blockedUser: String) {
        self.myblockingUser = myblockingUser
        self.blockedUser = blockedUser
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.myblockingUser = try container.decode(String.self, forKey: .myblockingUser)
        self.blockedUser = try container.decode(String.self, forKey: .blockedUser)
    }
}
