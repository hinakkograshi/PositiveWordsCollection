//
//  DatabasePostField.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/06/02.
//

import Foundation

struct DatabasePostField {
    static let postID = "post_id"
    static let userID = "user_id"
    static let displayName = "display_name"
    static let caption = "caption"
    static let dateCreated = "date_created"
    static let likedBy = "liked_by" // sub-collection
    static let comments = "comments" // sub-collection
}
