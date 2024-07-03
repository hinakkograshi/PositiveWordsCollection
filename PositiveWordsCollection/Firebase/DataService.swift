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
extension Query {
    //    func getDocument<T>(as type: T.Type) async throws -> [T] where T: Decodable {
    //        try await getDocumentWithSnapshot(as: type).products
    //    }
    
    func getDocumentWithSnapshot<T>(as type: T.Type) async throws -> (products: [T], lastDocument: DocumentSnapshot?) where T: Decodable {
        let snapshot = try await self.getDocuments()
        let products = try snapshot.documents.map { document in
            try document.data(as: T.self)
        }
        return(products, snapshot.documents.last)
    }
}

class DataService {
    static let instance = DataService()
    private var postsCollection = Firestore.firestore().collection("posts")
    private var reportsCollection = Firestore.firestore().collection("reports")
    private let userCollection = Firestore.firestore().collection("users")
    private func commentSubCollection(postId: String) -> CollectionReference {
        postsCollection.document(postId).collection("comments")
    }
    private func likedBySubCollection(postId: String) -> CollectionReference { postsCollection.document(postId).collection("liked_by")
    }
    
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    func createPostId() -> String {
        let document = postsCollection.document()
        let postID = document.documentID
        return postID
    }
    
    // MARK: Get functions
    func downloadPostForUser(userID: String) async throws -> [PostModel] {
        let userPosts = try await postsCollection.whereField(DatabaseHelperField.userID, isEqualTo: userID).getDocuments().documents.compactMap {
            try? $0.data(as: Post.self)
        }
        return try await getPostsFromSnapshot(posts: userPosts)
    }
    // UserIDの投稿を取得
    func getUserFeed(userId: String, lastDocument: DocumentSnapshot?) async throws -> ([PostModel], lastDocument: DocumentSnapshot?) {
        // First FiveData
        if let lastDocument {
            let (postsQuery, lastDoc) = try await postsCollection
                .whereField(DatabaseHelperField.userID, isEqualTo: userId)
                .limit(to: 5)
                .start(afterDocument: lastDocument)
                .getDocumentWithSnapshot(as: Post.self)
            let posts = try await getPostsFromSnapshot(posts: postsQuery)
            return (posts, lastDoc)
        } else {
            let (postsQuery, lastDoc) = try await postsCollection
                .whereField(DatabaseHelperField.userID, isEqualTo: userId)
                .limit(to: 5)
                .getDocumentWithSnapshot(as: Post.self)
            let posts = try await getPostsFromSnapshot(posts: postsQuery)
            return (posts, lastDoc)
        }
    }
    
    // Pagination
    func getHomeScrollPostsForFeed(lastDocument: DocumentSnapshot?) async throws -> ([PostModel], lastDocument: DocumentSnapshot?) {
        // First FiveData
        if let lastDocument {
            let (postsQuery, lastDoc) = try await postsCollection
                .order(by: DatabaseHelperField.dateCreated, descending: true)
                .limit(to: 5)
                .start(afterDocument: lastDocument)
                .getDocumentWithSnapshot(as: Post.self)
            let posts = try await getPostsFromSnapshot(posts: postsQuery)
            //            print("🟩true:\(lastDocument)")
            return (posts, lastDoc)
        } else {
            let (postsQuery, lastDoc) = try await postsCollection
                .order(by: DatabaseHelperField.dateCreated, descending: true)
                .limit(to: 5).getDocumentWithSnapshot(as: Post.self)
            print("🐥🐥POST:\(postsQuery)")
            let posts = try await getPostsFromSnapshot(posts: postsQuery)
            //            print("🟥false:\(lastDocument)")
            return (posts, lastDoc)
        }
    }
    
    private func getPost(post: Post) async throws -> PostModel {
        let likeCount = try await likeCount(postID: post.postId)
        let commentCount = try await commentCount(postID: post.postId)
        var likeByUser: Bool = false
        // ❤️自分がいいねを押したか？UserID
        if let userID = currentUserID {
            likeByUser = try await DataService.instance.myLiked(postID: post.postId, userID: userID)
        }
        // NewPost
        let newPost = PostModel(postID: post.postId, userID: post.userId, username: post.displayName, caption: post.caption, dateCreated: post.dateCreated, likeCount: likeCount, likedByUser: likeByUser, comentsCount: commentCount)
        return newPost
    }
    
    private func getPostsFromSnapshot(posts: [Post]) async throws -> [PostModel] {
        var postArray = [PostModel]()
        for post in posts {
            let likeCount = try await likeCount(postID: post.postId)
            let commentCount = try await commentCount(postID: post.postId)
            var likeByUser: Bool = false
            // ❤️自分がいいねを押したか？UserID
            if let userID = currentUserID {
                likeByUser = try await DataService.instance.myLiked(postID: post.postId, userID: userID)
            }
            // NewPost
            let newPost = PostModel(postID: post.postId, userID: post.userId, username: post.displayName, caption: post.caption, dateCreated: post.dateCreated, likeCount: likeCount, likedByUser: likeByUser, comentsCount: commentCount)
            postArray.append(newPost)
        }
        return postArray
    }
    
    private func getCommentsFromSnapshot(comments: [Comment]) -> [CommentModel] {
        var commentArray = [CommentModel]()
        for comment in comments {
            let newComment = CommentModel(commentID: comment.commentId, userID: comment.userId, username: comment.displayName, content: comment.content, dateCreated: comment.dateCreated)
            commentArray.append(newComment)
        }
        return commentArray
    }
    
    func downloadComments(postID: String) async throws -> [CommentModel] {
        let comments = try await commentSubCollection(postId: postID).order(by: DatabaseHelperField.dateCreated, descending: false).getDocuments().documents.compactMap { try? $0.data(as: Comment.self)
        }
        return getCommentsFromSnapshot(comments: comments)
    }
    
    // MARK: UPDATE FUNCTION
    func uploadPost(post: Post, image: UIImage) async {
        do {
            try await ImageManager.instance.uploadPostImage(postID: post.postId, image: image)
            try postsCollection.document(post.postId).setData(from: post, encoder: encoder)
        } catch {
            print("🟥Error uploading post image to firebase")
        }
    }
    // 🟥報告
    func uploadReport(reports: Report) throws {
        try reportsCollection.document().setData(from: reports, encoder: encoder)
    }
    
    func createCommentId(postID: String) -> String {
        let document = commentSubCollection(postId: postID).document()
        let commentID = document.documentID
        return commentID
    }
    
    // MARK: UPDATE FUNCTION
    // commentsSubCollection
    func uploadComment(comment: Comment, postID: String) async {
        do {
            try commentSubCollection(postId: postID).document(comment.commentId).setData(from: comment, encoder: encoder)
        } catch {
            print("uploadComment Error")
        }
    }
    //　❤️
    func myLiked(postID: String, userID: String) async throws -> Bool {
        let query = likedBySubCollection(postId: postID).whereField(DatabaseHelperField.userID, isEqualTo: userID)
        let countQuery = query.count
        let myLikeCountSnapshot = try await countQuery.getAggregation(source: .server)
        print(myLikeCountSnapshot.count)
        let count = myLikeCountSnapshot.count as? Int ?? 0
        if count >= 1 {
            return true
        } else {
            return false
        }
    }
    // 💛
    func likeCount(postID: String) async throws -> Int {
        let query = likedBySubCollection(postId: postID)
        let countQuery = query.count
        let snapshot = try await countQuery.getAggregation(source: .server)
        return snapshot.count as? Int ?? 0
    }
    
    // 🐥
    func sumLikePost(userID: String) async throws -> Int {
        let userPostModel = try await downloadPostForUser(userID: userID)
        var sum = 0
        print("🩵userPostModel：\(userPostModel)")
        for post in userPostModel {
            print("🩵userPostModel：\(post)")
            let like = try await likeCount(postID: post.postID)
            sum += like
            print("🩵like：\(like)")
            print("🩵sum：\(sum)")
        }
        return sum
    }
    
    
    // 💛
    func unLikePost(postID: String, myUserID: String) async throws {
        let query = likedBySubCollection(postId: postID).whereField(DatabaseHelperField.userID, isEqualTo: myUserID)
        let snapShot = try await query.getDocuments()
        for document in snapShot.documents {
            try await document.reference.delete()
        }
    }
    // 🩵
    func likePost(postID: String, currentUserID: String) {
        // Update post count
        // Update who liked
        let increment: Int64 = 1
        let data: [String: Any] = [
            DatabaseHelperField.likeCount: FieldValue.increment(increment)
        ]
        postsCollection.document(postID).updateData(data)
    }
    // 🩵
    func unlikePost(postID: String, currentUserID: String) {
        let decrement: Int64 = -1
        let data: [String: Any] = [
            DatabaseHelperField.likeCount: FieldValue.increment(decrement)
        ]
        postsCollection.document(postID).updateData(data)
    }
    // 🩵
    func commentPostCount(postID: String, currentUserID: String) async throws {
        let commentArray = try await downloadComments(postID: postID)
        let increment: Int64 = 1
        let data: [String: Any] = [
            DatabaseHelperField.commentCount: FieldValue.increment(increment)
        ]
        try await postsCollection.document(postID).updateData(data)
    }
    
    func uploadLikedPost(postID: String, like: Like) throws {
        let document = likedBySubCollection(postId: postID).document(like.userId)
        try document.setData(from: like, encoder: encoder)
    }
    
    func commentCount(postID: String) async throws -> Int {
        let query = commentSubCollection(postId: postID)
        let countQuery = query.count
        let snapshot = try await countQuery.getAggregation(source: .server)
        return snapshot.count as? Int ?? 0
    }
    // 🐥
    func sumUserPost(userID: String) async throws -> Int {
        let query = postsCollection.whereField(DatabaseHelperField.userID, isEqualTo: userID)
        let countQuery = query.count
        let snapshot = try await countQuery.getAggregation(source: .server)
        return snapshot.count as? Int ?? 0
    }
    
    // MARK: UPDATE USER FUNCTION
    func updateDisplayNameOnPosts(userID: String, displayName: String) async throws {
        let posts = try await downloadPostForUser(userID: userID)
        // 100件あって一部名前変更全部成功かどうか
        for post in posts {
            self.updatePostDisplayName(postID: post.postID, displayName: displayName)
        }
    }
    
    private func updatePostDisplayName(postID: String, displayName: String) {
        let data: [String: Any] = [
            DatabaseHelperField.displayName: displayName
        ]
        postsCollection.document(postID).updateData(data)
    }
}
