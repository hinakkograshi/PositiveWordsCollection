//
//  PostArrayObject.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/22.
//

import Foundation

class PostArrayObject: ObservableObject {
    @Published var dataArray = [PostModel]()
    @Published var postCountString = "0"
    @Published var likeCountString = "0"

    /// Used for single post selection
    init(post: PostModel) {
        self.dataArray.append(post)
    }

    /// USERがProfilrの投稿を取得するために使用
    init(userID: String) {
        Task {
            print("get posts for user ID \(userID)")
            do {
                let returnedposts = try await DataService.instance.downloadPostForUser(userID: userID)
                // 最新の日付
                let sortedPosts = returnedposts.sorted { (post1, post2) -> Bool in
                    return post1.dateCreated > post2.dateCreated
                }
                self.dataArray.append(contentsOf: sortedPosts)
                self.updateCounts()
            } catch {
                print("get posts for user Error")

            }
        }
    }
    // User for Feed
    init(shuffled: Bool) {
        print("Get Post Fpr Feed. Shuffle \(shuffled)")
        DataService.instance.downloadPostsForFeed { returnedPosts in
            if shuffled {
                let shuffledPosts = returnedPosts.shuffled()
                self.dataArray.append(contentsOf: shuffledPosts)
            } else {
                self.dataArray.append(contentsOf: returnedPosts)
            }
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

    init() {
        print("データベースから投稿をfetch")
        let post1 = PostModel(postID: "", userID: "", username: "hinakko", caption: "", dateCreated: Date(), likeCount: 0, likedByUser: false)
        let post2 = PostModel(postID: "", userID: "", username: "hinakko", caption: "", dateCreated: Date(), likeCount: 0, likedByUser: false)
        let post3 = PostModel(postID: "", userID: "", username: "hinakko", caption: "", dateCreated: Date(), likeCount: 0, likedByUser: false)
        let post4 = PostModel(postID: "", userID: "", username: "hinakko", caption: "This is a test caption", dateCreated: Date(), likeCount: 0, likedByUser: false)

        dataArray.append(post1)
        dataArray.append(post2)
        dataArray.append(post3)
        dataArray.append(post4)
    }
}
