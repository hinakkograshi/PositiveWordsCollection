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
    @Published var loadingState: LoadingState = .idle
    @Published var profileViewOn = false
    @Published var myPostCountString = ""
    @Published var myLikeCountString = ""
    @Published var userPostCountString = ""
    @Published var userLikeCountString = ""
    private var lastDocument: DocumentSnapshot? = nil
    private var lastUserDocument: DocumentSnapshot? = nil
    private var lastMyUserDocument: DocumentSnapshot? = nil
    
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
    
    func refreshHomeFirst(hiddenPostIDs: [String], myUserID: String) async {
        dataArray = []
        lastDocument = nil
        do {
            loadingState = .loading
            let (newPosts, lastDocument) = try await DataService.instance.getHomeScrollPostsForFeed(lastDocument: lastDocument, hiddenPostIDs: hiddenPostIDs, myUserID: myUserID)
            self.dataArray.append(contentsOf: newPosts)
            loadingState = .success
            if let lastDocument {
                self.lastDocument = lastDocument
            }
        } catch {
            loadingState = .failure
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
            // 最新の日付
            let sortedPosts = newPosts.sorted { (post1, post2) -> Bool in
                return post1.dateCreated > post2.dateCreated
            }
            self.myUserPostArray.append(contentsOf: sortedPosts)
            if let lastMyUserDocument {
                self.lastMyUserDocument = lastMyUserDocument
            } else {
                // nilならば
                isMyLastPost = true
            }
        } catch {
            print("🟥refreshMyUserPost Error")
        }
        return isMyLastPost
    }
    
    func resetUserPostArray() {
        userPostArray = []
        lastUserDocument = nil
    }
    
    func refreshUserPost(userID: String) async -> (Bool) {
        profileViewOn = true
        var isLastPost = false
        do {
            let (newPosts, lastUserDocument) = try await DataService.instance.getUserFeed(userId: userID, lastDocument: lastUserDocument)
            // 最新の日付
            let sortedPosts = newPosts.sorted { (post1, post2) -> Bool in
                return post1.dateCreated > post2.dateCreated
            }
            self.userPostArray.append(contentsOf: sortedPosts)
            if let lastUserDocument {
                self.lastUserDocument = lastUserDocument
            } else {
                // nilならば
                isLastPost = true
            }
        } catch {
            print("🟥refreshUserPost Error")
        }
        return isLastPost
    }
    
    func updateUserCounts(userID: String) {
        userPostCountString = ""
        userLikeCountString = ""
        Task {
            do {
                let sum = try await DataService.instance.sumLikePost(userID: userID)
                userLikeCountString = "\(sum)"
            } catch {
                print(error)
            }
            do {
                let postCount = try await DataService.instance.sumUserPost(userID: userID)
                userPostCountString = String(postCount)
            } catch {
                print("PostCount Error")
            }
        }
    }
    
    func updateMyCounts(userID: String) {
        myPostCountString = ""
        myLikeCountString = ""
        Task {
            do {
                let sum = try await DataService.instance.sumLikePost(userID: userID)
                myLikeCountString = "\(sum)"
            } catch {
                print(error)
            }
            do {
                let postCount = try await DataService.instance.sumUserPost(userID: userID)
                myPostCountString = String(postCount)
            } catch {
                print("PostCount Error")
            }
        }
    }
}
