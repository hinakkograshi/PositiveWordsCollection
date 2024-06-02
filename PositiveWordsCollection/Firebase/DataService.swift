//
//  DataService.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/06/02.
//

import Foundation
import SwiftUI
import FirebaseFirestore

let db = Firestore.firestore()
class DataService {
    static let instance = DataService()
    private var postsREF = db.collection("posts")
    private var reportsREF = db.collection("reports")
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?

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
    func uploadReport(reason: String, postID: String, handler: @escaping (_ success: Bool) -> Void) {
        let data: [String: Any] = [
            DatabaseReportsField.content: reason,
            DatabaseReportsField.postID: postID,
            DatabaseReportsField.dateCreated: FieldValue.serverTimestamp()

        ]
        reportsREF.addDocument(data: data) { error in
            if let error = error {
                print("Error uploadomg report.\(error)")
                handler(false)
                return
            } else {
                handler(true)
                return
            }
        }
    }

    func uploadComment(postID: String, content: String, displayName: String, userID: String, handler: @escaping (_ success: Bool, _ commentID: String?) -> Void) {
        let document = postsREF.document(postID).collection(DatabasePostField.comments).document()
        let commentID = document.documentID
        let data: [String: Any] = [
            DatabaseCommentsField.commentID: commentID,
            DatabaseCommentsField.userID: userID,
            DatabaseCommentsField.content: content,
            DatabaseCommentsField.displayName: displayName,
            DatabaseCommentsField.dateCreated: FieldValue.serverTimestamp()
        ]
        document.setData(data) { error in
            if let error = error {
                print("Error uploading comment. \(error)")
                handler(false, nil)
            } else {
                handler(true, commentID)
                return
            }
        }
    }
    // MARK: Get functions
    func downloadPostForUser(userID: String, handler: @escaping (_ posts: [PostModel]) -> Void) {
        postsREF.whereField(DatabasePostField.userID, isEqualTo: userID).getDocuments { querySnapshot, _ in
            handler(self.getPostsFromSnapshot(querySnapshot: querySnapshot))
        }
    }

    func downloadPostsForFeed(handler: @escaping (_ posts: [PostModel]) -> Void) {
        // 最新の50個しか取得しない
        postsREF.order(by: DatabasePostField.dateCreated, descending: true).limit(to: 50).getDocuments { querySnapshot, _ in
            handler(self.getPostsFromSnapshot(querySnapshot: querySnapshot))
        }
    }

    private func getPostsFromSnapshot(querySnapshot: QuerySnapshot?) -> [PostModel] {
        var postArray = [PostModel]()
        if let snapshot = querySnapshot, snapshot.documents.count > 0 {
            for document in snapshot.documents {
                if let userID = document.get(DatabasePostField.userID) as? String,
                   let displayName = document.get(DatabasePostField.displayName)as? String,
                   let timestamp = document.get(DatabasePostField.dateCreated) as? Timestamp {
                    let caption = document.get(DatabasePostField.caption) as? String
                    let date = timestamp.dateValue()
                    let postID = document.documentID
                    let likeCount = document.get(DatabasePostField.likeCount) as? Int ?? 0
                    var likeByUser: Bool = false

                    if let userIDArray = document.get(DatabasePostField.likeBy) as? [String], let userID = currentUserID {
                        likeByUser = userIDArray.contains(userID)
                    }
                    // NewPost
                    let newPost = PostModel(postID: postID, userID: userID, username: displayName, caption: caption, dateCreated: date, likeCount: likeCount, likedByUser: likeByUser)
                    postArray.append(newPost)
                }
            }
            return postArray
        } else {
            print("No document is snapshot found for this user")
            return postArray
        }
    }

    func downloadComments(postID: String, handler: @escaping (_ comments: [CommentModel]) -> Void) {
        postsREF.document(postID).collection(DatabasePostField.comments).order(by: DatabaseCommentsField.dateCreated, descending: false).getDocuments { querySnapshot, _ in
            handler(self.getCommentsFromSnapshot(querySnapshot: querySnapshot))
        }
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
    func likePost(postID: String, currentUserID: String) {
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

    func updateDisplayNameOnPosts(userID: String, displayName: String) {
        downloadPostForUser(userID: userID) { [self] posts in
            for post in posts {
                self.updatePostDisplayName(postID: post.postID, displayName: displayName)
            }
        }
    }

    private func updatePostDisplayName(postID: String, displayName: String) {
        let data: [String: Any] = [
            DatabasePostField.displayName: displayName
        ]
        postsREF.document(postID).updateData(data)
    }
}
