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
    
    func refreshUpdateHome(hiddenPostIDs: [String], myUserID: String) async {
        dataArray = []
        lastDocument = nil
        do {
            let (newPosts, lastDocument) = try await DataService.instance.getHomeScrollPostsForFeed(lastDocument: lastDocument, hiddenPostIDs: hiddenPostIDs, myUserID: myUserID)
            self.dataArray.append(contentsOf: newPosts)
            if let lastDocument {
                self.lastDocument = lastDocument
            }
        } catch {
            print("🟥refreshAllUserPosts Error: \(error)")
            print("\(error)")
        }
    }
    func refreshUpdateMyUserPost(userID: String) async {
        myUserPostArray = []
        lastMyUserDocument = nil
        do {
            let (newPosts, lastMyUserDocument) = try await DataService.instance.getUserFeed(userId: userID, lastDocument: lastMyUserDocument)
            // 最新の日付
            let sortedPosts = newPosts.sorted { (post1, post2) -> Bool in
                return post1.dateCreated > post2.dateCreated
            }
            self.myUserPostArray.append(contentsOf: sortedPosts)
            self.lastMyUserDocument = lastMyUserDocument
        } catch {
            print("🟥refreshUpdateMyUserPost Error")
        }
    }
    
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
                //                    self.updateCounts(userID: userID)
            } else {
                // nilならば
                isMyLastPost = true
            }
        } catch {
            print("🟥refreshMyUserPost Error")
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
                //                    self.updateCounts(userID: userID)
            } else {
                // nilならば
                isLastPost = true
            }
        } catch {
            print("🟥refreshUserPost Error")
        }
        return isLastPost
    }
    
    func refreshHome(hiddenPostIDs: [String], myUserID: String) async -> (Bool) {
        var isLastPost = false
        do {
            let (newPosts, lastDocument) = try await DataService.instance.getHomeScrollPostsForFeed(lastDocument: lastDocument, hiddenPostIDs: hiddenPostIDs, myUserID: myUserID)
            self.dataArray.append(contentsOf: newPosts)
            if let lastDocument {
                self.lastDocument = lastDocument
            } else {
                // 最後nil
                isLastPost = true
            }
        } catch {
            print("🟥refreshHome: \(error)")
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
                print(error)
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
