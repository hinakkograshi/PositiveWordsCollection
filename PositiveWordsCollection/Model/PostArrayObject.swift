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
    @Published var myUserPostArray: [PostModel] = []
    // ProfileViewが一度も表示されていない時ポスト追加
    @Published var profileViewOn = false
    @Published var postCountString = "0"
    @Published var likeCountString = "0"
    private var lastDocument: DocumentSnapshot? = nil
    private var lastUserDocument: DocumentSnapshot? = nil
    private var lastMyUserDocument: DocumentSnapshot? = nil

    func refreshMyUserPost(userID: String) async -> (Bool) {
        profileViewOn = true
        var isMyLastPost = false
            do {
                let (newPosts, lastMyUserDocument) = try await DataService.instance.getUserFeed(userId: userID, lastDocument: lastMyUserDocument)
                print("🟥\(newPosts)")
                // 最新の日付
                let sortedPosts = newPosts.sorted { (post1, post2) -> Bool in
                    return post1.dateCreated > post2.dateCreated
                }
                print("🟩\(myUserPostArray)")
                self.myUserPostArray.append(contentsOf: sortedPosts)
                print("🐥\(myUserPostArray)")
                if let lastMyUserDocument {
                    self.lastMyUserDocument = lastMyUserDocument
//                    self.updateCounts(userID: userID, postArray: myUserPostArray)
                } else {
                    // nilならば
                    isMyLastPost = true
                }
            } catch {
                print("🟥refreshAllUserPosts Error")
            }
        return isMyLastPost
    }

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
//                    self.updateCounts(userID: userID, postArray: userPostArray)
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
            do {
                let (newPosts, lastDocument) = try await DataService.instance.getHomeScrollPostsForFeed(lastDocument: lastDocument)
                self.dataArray.append(contentsOf: newPosts)
                if let lastDocument {
                    self.lastDocument = lastDocument
                } else {
                    // 最後nil
                    isLastPost = true
                }
            } catch {
                print("🟥refreshAllUserPosts Error")
            }
        return isLastPost
    }

    // like
    func updateCounts(userID: String) {
        postCountString = "0"
        likeCountString = "0"
        Task {
            do {
                let sum = try await DataService.instance.sumLikePost(userID: userID)
                likeCountString = "\(sum)"
                print("🩵いいね数\(sum)")
            } catch {
                print("🩵SumLike Error")
            }
            do {
                let postCount = try await DataService.instance.sumUserPost(userID: userID)
                postCountString = String(postCount)
            } catch {
                print("PostCount Error")
            }
        }
    }
}
