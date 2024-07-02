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
    @Published var userPostArray: [PostModel] = []
    // ProfileViewが一度も表示されていない時ポスト追加
    @Published var profileViewOn = false
    @Published var postCountString = "0"
    @Published var likeCountString = "0"
    private var lastDocument: DocumentSnapshot? = nil
    private var lastUserDocument: DocumentSnapshot? = nil

    func refreshUserPost(userID: String) async -> (Bool) {
        profileViewOn = true
        var isLastPost = false
            do {
                let (newPosts, lastUserDocument) = try await DataService.instance.getUserFeed(userId: userID, lastDocument: lastUserDocument)
                print("🟥\(newPosts)")
                // 最新の日付
                let sortedPosts = newPosts.sorted { (post1, post2) -> Bool in
                    return post1.dateCreated > post2.dateCreated
                }
                print("🟩\(userPostArray)")
                self.userPostArray.append(contentsOf: sortedPosts)
                print("🐥\(userPostArray)")
                if let lastUserDocument {
                    self.lastUserDocument = lastUserDocument
                    self.updateCounts()
                } else {
                    // nilならば
                    isLastPost = true
                }
            } catch {
                print("🟥refreshAllUserPosts Error")
            }
        return isLastPost
    }

    func refreshHome() async -> (Bool) {
        var isLastPost = false
//        print("⭐️LastDOC:\(lastDocument)")
            do {
                let (newPosts, lastDocument) = try await DataService.instance.getHomeScrollPostsForFeed(lastDocument: lastDocument)
                self.dataArray.append(contentsOf: newPosts)
                if let lastDocument {
                    self.lastDocument = lastDocument
                } else {
                    // nilならば
                    isLastPost = true
                    print("⭐️isLastPost TRUE")
                }
                // 最後nil
//                print("⭐️ReturnDOC:\(lastDocument)")
            } catch {
                print("🟥refreshAllUserPosts Error")
            }
        print("⭐️isLastPost TRUE:::::\(isLastPost)")
        return isLastPost
    }

    // like
    private func updateCounts() {
        // Count
        self.postCountString = "\(self.userPostArray.count)"
        print("🩵ポスト数\(postCountString)")
        let likeCountArray = userPostArray.map({ (existPost) -> Int in
            return existPost.likeCount
        })
        print("🩵いいね数\(likeCountArray)")
        let sumOfLikeCountArray = likeCountArray.reduce(0, +)
        // Like
        self.likeCountString = "\(sumOfLikeCountArray)"
        print(likeCountString)
    }
}
