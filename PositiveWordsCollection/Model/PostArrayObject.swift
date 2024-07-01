//
//  PostArrayObject.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/22.
//

import Foundation
import FirebaseFirestore
@MainActor
class PostArrayObject: ObservableObject {
    @Published var dataArray: [PostModel] = []
    @Published var postCountString = "0"
    @Published var likeCountString = "0"
    private var lastDocument: DocumentSnapshot? = nil

    func refreshUserPost(userID: String) {
        Task {
            do {
                let (newPosts, lastDocument) = try await DataService.instance.downloadUserFeed(userId: userID, lastDocument: lastDocument)
                print("🟥\(newPosts)")
                // 最新の日付
                let sortedPosts = newPosts.sorted { (post1, post2) -> Bool in
                    return post1.dateCreated > post2.dateCreated
                }
                print("🟩\(dataArray)")
                self.dataArray.append(contentsOf: sortedPosts)
                print("🐥\(dataArray)")
                self.lastDocument = lastDocument
                self.updateCounts()
            } catch {
                print("🟥refreshAllUserPosts Error")
            }
        }
    }

    func refreshHome() {
        Task {
            do {
                let (newPosts, lastDocument) = try await DataService.instance.downloadHomeScrollPostsForFeed(lastDocument: lastDocument)
                self.dataArray.append(contentsOf: newPosts)
                self.lastDocument = lastDocument
            } catch {
                print("🟥refreshAllUserPosts Error")
            }
        }
    }

    // like
    private func updateCounts() {
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
}
