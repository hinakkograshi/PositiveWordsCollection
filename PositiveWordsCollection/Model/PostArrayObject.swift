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
            await refreshAllUserPosts()
        }
    }

    // USERがMyProfileの投稿を取得するために使用
    init(userID: String) {
            Task {
                await refreshOfUser(userID: userID)
            }
    }
// like
    func updateCounts() {
        // Count
        self.postCountString = "\(self.dataArray.count)"
        print("🩵ポスト数\(postCountString)")
        let likeCountArray = dataArray.map({ (existPost) -> Int in
            return existPost.likeCount
        })
        print("🩵いいね数\(likeCountArray)")
        let sumOfLikeCountArray = likeCountArray.reduce(0, +)
        // Like
        self.likeCountString = "\(sumOfLikeCountArray)"
        print(likeCountString)
    }
    func refreshAllUserPosts() async {
        do {
            let returnedPosts = try await DataService.instance.downloadPostsForFeed()
            self.dataArray = returnedPosts
        } catch {
            print("🟥refreshAllUserPosts Error")
        }
    }
    func refreshOfUser(userID: String) async {
        do {
            let returnedposts = try await DataService.instance.downloadPostForUser(userID: userID)
        // 最新の日付
        let sortedPosts = returnedposts.sorted { (post1, post2) -> Bool in
            return post1.dateCreated > post2.dateCreated
        }
        self.dataArray = sortedPosts
        self.updateCounts()
        } catch {
            print("refreshOfUser Error")
        }
    }
}
