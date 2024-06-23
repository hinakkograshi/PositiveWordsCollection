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

struct Post: Codable {
    var postId: String
    var userId: String
    var displayName: String
    var caption: String
    var dateCreated: Date

    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case userId = "user_id"
        case displayName = "display_name"
        case caption = "caption"
        case dateCreated = "date_created"
    }

    init(postId: String, userId: String, displayName: String, caption: String, dateCreated: Date) {
        self.postId = postId
        self.userId = userId
        self.displayName = displayName
        self.caption = caption
        self.dateCreated = dateCreated
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postId = try container.decode(String.self, forKey: .postId)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.displayName = try container.decode(String.self, forKey: .displayName)
        self.caption = try container.decode(String.self, forKey: .caption)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
}

struct Comment: Codable {
    var commentId: String
    var userId: String
    var displayName: String
    var content: String
    var dateCreated: Date

    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case userId = "user_id"
        case displayName = "display_name"
        case content = "content"
        case dateCreated = "date_created"
    }

    init(commentId: String, userId: String, displayName: String, content: String, dateCreated: Date) {
        self.commentId = commentId
        self.userId = userId
        self.displayName = displayName
        self.content = content
        self.dateCreated = dateCreated
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.commentId = try container.decode(String.self, forKey: .commentId)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.displayName = try container.decode(String.self, forKey: .displayName)
        self.content = try container.decode(String.self, forKey: .content)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
}

class DataService {
    static let instance = DataService()
    private var postsREF = Firestore.firestore().collection("posts")
    private var reportsREF = Firestore.firestore().collection("reports")
    private let userCollection = Firestore.firestore().collection("users")
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?

    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    func createPostId() -> String {
        let document = postsREF.document()
        let postID = document.documentID
        return postID
    }

    // MARK: UPDATE FUNCTION
    func uploadPost(post: Post, image: UIImage) async {
        // Upload image to Storage
        do {
            try await ImageManager.instance.uploadPostImage(postID: post.postId, image: image)
            try postsREF.document().setData(from: post, merge: false, encoder: encoder)
        } catch {
            print("🟥Error uploading post image to firebase")
        }
    }

    // MARK: Get functions
    // UserIDの投稿を取得
    func downloadPostForUser(userID: String) async throws -> [PostModel] {
        let userPosts = try await postsREF.whereField(DatabasePostField.userID, isEqualTo: userID).getDocuments().documents.compactMap {
            try? $0.data(as: Post.self)
        }
        return try await getPostsFromSnapshot(posts: userPosts)
    }

    // 最新の50個のポスト取得
    func downloadPostsForFeed() async throws -> [PostModel] {
        // 最新の50個しか取得しない
        let downloadPosts = try await postsREF.order(by: DatabasePostField.dateCreated, descending: true).limit(to: 50).getDocuments().documents.compactMap {
            try? $0.data(as: Post.self)
        }
        return try await getPostsFromSnapshot(posts: downloadPosts)
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
            let commentId = comment.commentId
            let userId = comment.userId
            let displayName = comment.displayName
            let content = comment.content
            let dateCreated = comment.dateCreated
            let newComment = CommentModel(commentID: commentId, userID: userId, username: displayName, content: content, dateCreated: dateCreated)
            commentArray.append(newComment)
        }
        return commentArray
    }

    func downloadComments(postID: String) async throws -> [CommentModel] {
        let comments = try await postsREF.document(postID).collection(DatabasePostField.comments).order(by: DatabaseCommentsField.dateCreated, descending: false).getDocuments().documents.compactMap { try? $0.data(as: Comment.self)
        }
        return getCommentsFromSnapshot(comments: comments)
    }

    // 🟥報告
    func uploadReport(postID: String) async throws {
        let data: [String: Any] = [
            DatabaseReportsField.postID: postID,
            DatabaseReportsField.dateCreated: FieldValue.serverTimestamp()
        ]
        try await reportsREF.addDocument(data: data)
    }

    func createCommentId(postID: String) -> String {
        let document = postsREF.document(postID).collection(DatabasePostField.comments).document()
        let commentID = document.documentID
        return commentID
    }

    // MARK: UPDATE FUNCTION
    // commentsSubCollection
    func uploadComment(comment: Comment, postID: String) async {
        do {
            try postsREF.document(postID).collection(DatabasePostField.comments).document().setData(from: comment)
        } catch {
            print("uploadComment Error")
        }
    }
    //　❤️
    func myLiked(postID: String, userID: String) async throws -> Bool {
        let query = postsREF.document(postID).collection(DatabasePostField.likedBy).whereField(DatabaseLikedByField.userID, isEqualTo: userID)
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
        let query = postsREF.document(postID).collection(DatabasePostField.likedBy)
        let countQuery = query.count
        let snapshot = try await countQuery.getAggregation(source: .server)
        print("🩵\(snapshot.count)❤️")
        return snapshot.count as? Int ?? 0
    }
    // 💛
    func unLikePost(postID: String, myUserID: String) async throws {
        let query = postsREF.document(postID).collection(DatabasePostField.likedBy).whereField(DatabaseLikedByField.userID, isEqualTo: myUserID)
        let snapShot = try await query.getDocuments()
        for document in snapShot.documents {
            try await document.reference.delete()
        }
    }
    // 💛
    func uploadLikedPost(postID: String, userID: String) async throws {
        let document = postsREF.document(postID).collection(DatabasePostField.likedBy).document()
        let data: [String: Any] = [
            DatabaseLikedByField.userID: userID,
            DatabaseLikedByField.dateCreated: FieldValue.serverTimestamp()
        ]
        try await document.setData(data)
    }
    func commentCount(postID: String) async throws -> Int {
        let query = postsREF.document(postID).collection(DatabasePostField.comments)
        let countQuery = query.count
        let snapshot = try await countQuery.getAggregation(source: .server)
        print("❤️\(snapshot.count)❤️")
        return snapshot.count as? Int ?? 0
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
