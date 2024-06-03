//
//  PostArrayObject.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/22.
//

import Foundation
@MainActor
class PostArrayObject: ObservableObject {
    @Published var dataArray = [PostModel]()
    @Published var postCountString = "0"
    @Published var likeCountString = "0"

    // All User Post
    init() {
        print("Get All User Post Home")
        Task {
            let returnedPosts = try await DataService.instance.downloadPostsForFeed()
            self.dataArray.append(contentsOf: returnedPosts)
        }
    }

    /// Used for single post selection
    init(post: PostModel) {
        self.dataArray.append(post)
    }

    /// USERがMyProfileの投稿を取得するために使用
    init(userID: String) {
        Task {
            print("get posts for user ID \(userID)")
                let returnedposts = try await DataService.instance.downloadPostForUser(userID: userID)
                // 最新の日付
                let sortedPosts = returnedposts.sorted { (post1, post2) -> Bool in
                    return post1.dateCreated > post2.dateCreated
                }
                self.dataArray.append(contentsOf: sortedPosts)
                self.updateCounts()
        }
    }

    func updateCounts() {
        self.postCountString = "\(self.dataArray.count)"
        let likeCountArray = dataArray.map({ (existPost) -> Int in
            return existPost.likeCount
        })
        print("いいね数\(likeCountArray)")
        let sumOfLikeCountArray = likeCountArray.reduce(0, +)
        self.likeCountString = "\(sumOfLikeCountArray)"
        print(likeCountString)
    }
}
