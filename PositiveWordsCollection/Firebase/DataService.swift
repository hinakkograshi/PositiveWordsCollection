//
//  DataService.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/06/02.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseStorage

class DataService {
    static let instance = DataService()
    private var postsREF = Firestore.firestore().collection("posts")
    private var reportsREF = Firestore.firestore().collection("reports")
    private let userCollection = Firestore.firestore().collection("users")
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?

    func postDelete(postID: String) async throws {
            // SubCollection Delete
            await subCollectionDelete(postID: postID)
            // PostCollection Delete
            try await Firestore.firestore().collection("posts").document(postID).delete()
            // Storage削除
            await postsStorageDelete(postID: postID)
    }
    // サブコレクションの削除が完了した後に親ドキュメントも削除する
    func deleteAccount(userID: String) async throws {
        // Authアカウント削除
        try await AuthService.instance.userAcountDelete()
        // UserDefault削除
        // All UserDefault Delete
        let defaultDictionary = UserDefaults.standard.dictionaryRepresentation()
        defaultDictionary.keys.forEach { key in
            UserDefaults.standard.removeObject(forKey: key)
        }
        await deleteUserCollection(userID: userID)
        // posts Collection of userID
        try await postAllDelete(userID: userID)
        // Storage削除
        await userStorageDelete(userID: userID)
        // users Collection Delete
        try await userCollection.document(userID).delete()
    }

    private func postAllDelete(userID: String) async throws {
        // posts Collection of userID
            let postOfUserSnapshot =  try await Firestore.firestore().collection("posts").whereField(DatabasePostField.userID, isEqualTo: userID).getDocuments()

        for document in postOfUserSnapshot.documents {
            let postID = document.documentID
            // SubCollection Delete
            await subCollectionDelete(postID: postID)
            print("⭐️これPostsDoCument\(document.documentID)⭐️")
            // PostCollection Delete
            try await Firestore.firestore().collection("posts").document(postID).delete()
            // Storage削除
            await postsStorageDelete(postID: postID)
        }
    }

    private func subCollectionDelete(postID: String) async {

        let subCollection = Firestore.firestore().collection("posts").document(postID).collection("comments")
        do {
            let subSnapshot = try await subCollection.getDocuments()
            for subdocument in subSnapshot.documents {
                try await subdocument.reference.delete()
            }
        } catch {
            print("subCollectionDelete Error")
        }
    }

    private func postsStorageDelete(postID: String) async {
        let storageRef = Storage.storage().reference()
        let postIDRef = storageRef.child("posts").child(postID).child("1")
        do {
            try await postIDRef.delete()
        } catch {
            print("postsStorageDelete Error")
        }
    }

    private func userStorageDelete(userID: String) async {
        let storageRef = Storage.storage().reference()
        let userIDRef = storageRef.child("users").child(userID).child("profile")
        do {
            try await userIDRef.delete()
        } catch {
            print("userStorageDelete Error")
        }
    }

    private func deleteUserCollection(userID: String) async {
        do {
            let usersAccountSnapshot = try await Firestore.firestore().collection("users").whereField(DatabasePostField.userID, isEqualTo: userID).getDocuments()
            for usersDocument in usersAccountSnapshot.documents {
                try await usersDocument.reference.delete()
            }
        } catch {
            print("deleteUserCollection Error")
        }
    }

    func uploadPost(image: UIImage, caption: String, displayName: String, userID: String) async {
        // Create new post document
        let document = postsREF.document()
        let postID = document.documentID
        // Upload image to Storage
        do {
            try await ImageManager.instance.uploadPostImage(postID: postID, image: image)
            let postData = [
                DatabasePostField.postID: postID,
                DatabasePostField.userID: userID,
                DatabasePostField.displayName: displayName,
                DatabasePostField.caption: caption,
                DatabasePostField.dateCreated: FieldValue.serverTimestamp()
            ] as [String: Any]
            try await document.setData(postData)
        } catch {
            print("Error uploading post image to firebase")
        }
    }
    // 🟥報告
    func uploadReport(postID: String) async throws {
        let data: [String: Any] = [
            DatabaseReportsField.postID: postID,
            DatabaseReportsField.dateCreated: FieldValue.serverTimestamp()
        ]
        try await reportsREF.addDocument(data: data)
    }

    func uploadComment(postID: String, content: String, displayName: String, userID: String) async throws -> String? {
        let document = postsREF.document(postID).collection(DatabasePostField.comments).document()
        let commentID = document.documentID
        let data: [String: Any] = [
            DatabaseCommentsField.commentID: commentID,
            DatabaseCommentsField.userID: userID,
            DatabaseCommentsField.content: content,
            DatabaseCommentsField.displayName: displayName,
            DatabaseCommentsField.dateCreated: FieldValue.serverTimestamp()
        ]
        try await document.setData(data)
        return commentID
    }
    // MARK: Get functions
    // UserIDの投稿を取得
    func downloadPostForUser(userID: String) async throws -> [PostModel] {
        let querySnapshot = try await postsREF.whereField(DatabasePostField.userID, isEqualTo: userID).getDocuments()
        let docData = querySnapshot.documents
        return getPostsFromSnapshot(querySnapshot: querySnapshot)
    }

    // 最新の50個のポスト取得
    func downloadPostsForFeed() async throws -> [PostModel] {
        // 最新の50個しか取得しない
        let querySnapshot = try await postsREF.order(by: DatabasePostField.dateCreated, descending: true).limit(to: 50).getDocuments()
        return getPostsFromSnapshot(querySnapshot: querySnapshot)
    }

    private func getPostsFromSnapshot(querySnapshot: QuerySnapshot?) -> [PostModel] {
        var postArray = [PostModel]()
        if let snapshot = querySnapshot, snapshot.documents.count > 0 {
            for document in snapshot.documents {
                if let userID = document.get(DatabasePostField.userID) as? String,
                   let displayName = document.get(DatabasePostField.displayName)as? String,
                   let timestamp = document.get(DatabasePostField.dateCreated) as? Timestamp,
                   let caption = document.get(DatabasePostField.caption) as? String {
                    let date = timestamp.dateValue()
                    let postID = document.documentID
                    let likeCount = document.get(DatabasePostField.likeCount) as? Int ?? 0
                    let commentCount = document.get(DatabasePostField.commentCount) as? Int ?? 0
                    var likeByUser: Bool = false
                    // 自分がいいねを押したか？UserID
                    if let userIDArray = document.get(DatabasePostField.likeBy) as? [String], let userID = currentUserID {
                        likeByUser = userIDArray.contains(userID)
                    }
                    // NewPost
                    let newPost = PostModel(postID: postID, userID: userID, username: displayName, caption: caption, dateCreated: date, likeCount: likeCount, likedByUser: likeByUser, comentsCount: commentCount)
                    postArray.append(newPost)
                }
            }
            return postArray
        } else {
            print("No document is snapshot found for this user")
            return postArray
        }
    }

    func downloadComments(postID: String) async throws -> [CommentModel] {
        let querySnapshot = try await postsREF.document(postID).collection(DatabasePostField.comments).order(by: DatabaseCommentsField.dateCreated, descending: false).getDocuments()
        return getCommentsFromSnapshot(querySnapshot: querySnapshot)
    }

    private func getCommentsFromSnapshot(querySnapshot: QuerySnapshot?) -> [CommentModel] {
        var commentArray = [CommentModel]()
        if let snapshot = querySnapshot, snapshot.documents.count > 0 {
            for document in snapshot.documents {
                if let userID = document.get(DatabaseCommentsField.userID) as? String,
                   let displayName = document.get(DatabaseCommentsField.displayName) as? String,
                   let content = document.get(DatabaseCommentsField.content) as? String,
                   let timestamp = document.get(DatabaseCommentsField.dateCreated) as? Timestamp {
                    let date = timestamp.dateValue()
                    let commentID = document.documentID
                    let newComment = CommentModel(commentID: commentID, userID: userID, username: displayName, content: content, dateCreated: date)
                    commentArray.append(newComment)
                }
            }
            return commentArray
        } else {
            print("No comment in document for this post")
            return commentArray
        }
    }

    // MARK: UPDATE FUNCTION
    // 🟥
    func commentPostCount(postID: String, currentUserID: String) async throws {
        let commentArray = try await downloadComments(postID: postID)
        let increment: Int64 = 1
        let data: [String: Any] = [
            DatabasePostField.commentCount: FieldValue.increment(increment)
        ]
        try await postsREF.document(postID).updateData(data)
    }
    func likePost(postID: String, currentUserID: String) {
        // Update post count
        // Update who liked
        let increment: Int64 = 1
        let data: [String: Any] = [
            DatabasePostField.likeCount: FieldValue.increment(increment),
            DatabasePostField.likeBy: FieldValue.arrayUnion([currentUserID])
        ]
        postsREF.document(postID).updateData(data)
    }

    func unlikePost(postID: String, currentUserID: String) {
        let decrement: Int64 = -1
        let data: [String: Any] = [
            DatabasePostField.likeCount: FieldValue.increment(decrement),
            DatabasePostField.likeBy: FieldValue.arrayRemove([currentUserID])
        ]
        postsREF.document(postID).updateData(data)
    }
    // MARK: UPDATE USER FUNCTION
    func updateDisplayNameOnPosts(userID: String, displayName: String) async throws {
        let posts = try await downloadPostForUser(userID: userID)
        for post in posts {
            self.updatePostDisplayName(postID: post.postID, displayName: displayName)
        }
    }

    private func updatePostDisplayName(postID: String, displayName: String) {
        let data: [String: Any] = [
            DatabasePostField.displayName: displayName
        ]
        postsREF.document(postID).updateData(data)
    }
}
