//
//  PostArrayObject.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/22.
//

import Foundation

class PostArrayObject: ObservableObject {
    @Published var dataArray = [PostModel]()

    init() {
        print("データベースから投稿をfetch")
        let post1 = PostModel(postID: "", userID: "", username: "hinakko", caption: "This is a test caption", dateCreated: Date(), likeCount: 0, likedByUser: false)
        let post2 = PostModel(postID: "", userID: "", username: "hinakko", dateCreated: Date(), likeCount: 0, likedByUser: false)
        let post3 = PostModel(postID: "", userID: "", username: "hinakko", caption: "This is a test caption", dateCreated: Date(), likeCount: 0, likedByUser: false)
        let post4 = PostModel(postID: "", userID: "", username: "hinakko", caption: "This is a test caption", dateCreated: Date(), likeCount: 0, likedByUser: false)
        let post5 = PostModel(postID: "", userID: "", username: "hinakko", caption: "This is a test caption", dateCreated: Date(), likeCount: 0, likedByUser: false)
        let post6 = PostModel(postID: "", userID: "", username: "hinakko", dateCreated: Date(), likeCount: 0, likedByUser: false)
        let post7 = PostModel(postID: "", userID: "", username: "hinakko", caption: "This is a test caption", dateCreated: Date(), likeCount: 0, likedByUser: false)
        let post8 = PostModel(postID: "", userID: "", username: "hinakko", caption: "This is a test caption", dateCreated: Date(), likeCount: 0, likedByUser: false)
        dataArray.append(post1)
        dataArray.append(post2)
        dataArray.append(post3)
        dataArray.append(post4)
        dataArray.append(post5)
        dataArray.append(post6)
        dataArray.append(post7)
        dataArray.append(post8)
    }
}
