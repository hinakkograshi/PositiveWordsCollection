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

    private func postDocument(postId: String) -> DocumentReference {
        postsCollection.document(postId)
    }
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

    func downloadPostForUser(userID: String) async throws -> [PostModel] {
        let userPosts = try await postsCollection.whereField(DatabaseHelperField.userID, isEqualTo: userID).getDocuments().documents.compactMap {
            try? $0.data(as: Post.self)
        }
        return try await getPostsFromSnapshot(posts: userPosts)
    }

    func getPost(from postId: String) async -> Post? {
        do {
            let post = try await postsCollection.document(postId).getDocument(as: Post.self)
            return post
        } catch {
            print("get post from postId")
            return nil
        }
    }
    // UserIDの投稿を取得
    func getUserFeed(userId: String, lastDocument: DocumentSnapshot?) async throws -> ([PostModel], lastDocument: DocumentSnapshot?) {
        // First FiveData
        if let lastDocument {
            let (postsQuery, lastDoc) = try await postsCollection
                .whereField(DatabaseHelperField.userID, isEqualTo: userId)
                .order(by: DatabaseHelperField.dateCreated, descending: true)
                .limit(to: 5)
                .start(afterDocument: lastDocument)
                .getDocumentWithSnapshot(as: Post.self)
            let posts = try await getPostsFromSnapshot(posts: postsQuery)
            return (posts, lastDoc)
        } else {
            let (postsQuery, lastDoc) = try await postsCollection
                .whereField(DatabaseHelperField.userID, isEqualTo: userId)
                .order(by: DatabaseHelperField.dateCreated, descending: true)
                .limit(to: 5)
                .getDocumentWithSnapshot(as: Post.self)
            let posts = try await getPostsFromSnapshot(posts: postsQuery)
            return (posts, lastDoc)
        }
    }

    // Pagination
    func getHomeScrollPostsForFeed(lastDocument: DocumentSnapshot?, hiddenPostIDs: [String], myUserID: String) async throws -> ([PostModel], lastDocument: DocumentSnapshot?) {
        let blockedUserIDs = try await AuthService.instance.getBlockedUser(myUserID: myUserID)
        // First FiveData
        if let lastDocument {
            if blockedUserIDs == [] {
                let (posts, lastDoc) = try await postsCollection
                    .order(by: DatabaseHelperField.dateCreated, descending: true)
                    .limit(to: 5)
                    .start(afterDocument: lastDocument)
                    .getDocumentWithSnapshot(as: Post.self)
                let filterPosts = try await downloadHiddenPost(hiddenPostIDs: hiddenPostIDs, newPosts: posts)
                let postModels = try await getPostsFromSnapshot(posts: filterPosts)
                return (postModels, lastDoc)
            } else {
                let (postsQuery, lastDoc) = try await postsCollection
                    .whereField(DatabaseHelperField.userID, notIn: blockedUserIDs)
                    .order(by: DatabaseHelperField.dateCreated, descending: true)
                    .limit(to: 5)
                    .start(afterDocument: lastDocument)
                    .getDocumentWithSnapshot(as: Post.self)
                let filterPosts = try await downloadHiddenPost(hiddenPostIDs: hiddenPostIDs, newPosts: postsQuery)
                let posts = try await getPostsFromSnapshot(posts: filterPosts)
                return (posts, lastDoc)
            }
        } else {
            if blockedUserIDs == [] {
                let (posts, lastDoc) = try await postsCollection
                    .order(by: DatabaseHelperField.dateCreated, descending: true)
                    .limit(to: 5).getDocumentWithSnapshot(as: Post.self)
                print("🐥🐥POST:\(posts)")
                let filterPosts = try await downloadHiddenPost(hiddenPostIDs: hiddenPostIDs, newPosts: posts)
                let postModels = try await getPostsFromSnapshot(posts: filterPosts)
                return (postModels, lastDoc)
            } else {
                let (postsQuery, lastDoc) = try await postsCollection
                    .whereField(DatabaseHelperField.userID, notIn: blockedUserIDs)
                    .order(by: DatabaseHelperField.dateCreated, descending: true)
                    .limit(to: 5)
                    .getDocumentWithSnapshot(as: Post.self)
                let filterPosts = try await downloadHiddenPost(hiddenPostIDs: hiddenPostIDs, newPosts: postsQuery)
                let posts = try await getPostsFromSnapshot(posts: filterPosts)
                return (posts, lastDoc)
            }
        }
    }

    // 🟥報告
    func uploadReport(reports: Report, handler: @escaping (_ success: Bool) -> Void) throws {
        try reportsCollection.document().setData(from: reports, encoder: encoder) { error in
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

    private func downloadHiddenPost(hiddenPostIDs: [String], newPosts: [Post]) async throws -> [Post] {
        var filterPosts = newPosts
        if hiddenPostIDs != [] {
            // hiddenPostIDsがからじゃなかったら
            for hiddenPostID in hiddenPostIDs {
                print("⭐️\(hiddenPostID)")
                do {
                    let hiddenPost = try  await postDocument(postId: hiddenPostID).getDocument().data(as: Post.self)
                    print(hiddenPost)
                } catch {
                    print(error)
                }
                for post in filterPosts where post.postId == hiddenPostID {
                    filterPosts.removeAll { $0 == post }
                    print("⭐️\(filterPosts)")
                }
                print("⭐️\(filterPosts)")
            }
        }
        return filterPosts
    }

    func likeByUserFromPostId(postId: String) async -> Bool {
        var likeByUser: Bool = false
        do {
            if let userID = currentUserID {
                likeByUser = try await DataService.instance.myLiked(postID: postId, userID: userID)
            }
        } catch {
            print("likeByUserFromPostId Error")
        }
        return likeByUser
    }

    private func getPostsFromSnapshot(posts: [Post]) async throws -> [PostModel] {
        var postArray = [PostModel]()
        for post in posts {
            var likeByUser: Bool = false
            // ❤️自分がいいねを押したか？UserID
            if let userID = currentUserID {
                likeByUser = try await DataService.instance.myLiked(postID: post.postId, userID: userID)
            }
            // NewPost
            let newPost = PostModel(postID: post.postId, userID: post.userId, username: post.displayName, caption: post.caption, dateCreated: post.dateCreated, likeCount: post.likeCount, likedByUser: likeByUser, comentsCount: post.commentCount)
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
        let comments = try await commentSubCollection(postId: postID).order(by: DatabaseHelperField.dateCreated, descending: false).getDocuments().documents
            .compactMap { try? $0.data(as: Comment.self)
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

    func sumLikePost(userID: String) async throws -> Int {
        let sum = try await Firestore.firestore()
            .collection("posts").whereField(DatabaseHelperField.userID, isEqualTo: userID)
            .aggregate([.sum("like_count")])
            .getAggregation(source: .server)
            .get(.sum("like_count")) as? Int ?? 0
        print("🩵\(sum)")
        return sum
    }

    func sumUserPost(userID: String) async throws -> Int {
        let query = postsCollection.whereField(DatabaseHelperField.userID, isEqualTo: userID)
        let countQuery = query.count
        let snapshot = try await countQuery.getAggregation(source: .server)
        return snapshot.count as? Int ?? 0
    }

    func unLikePost(postID: String, myUserID: String) async throws {
        let query = likedBySubCollection(postId: postID).whereField(DatabaseHelperField.userID, isEqualTo: myUserID)
        let snapShot = try await query.getDocuments()
        for document in snapShot.documents {
            try await document.reference.delete()
        }
    }

    func likePost(postID: String, currentUserID: String) {
        // Update post count
        // Update who liked
        let increment: Int64 = 1
        let data: [String: Any] = [
            DatabaseHelperField.likeCount: FieldValue.increment(increment)
        ]
        postsCollection.document(postID).updateData(data)
    }

    func unlikePost(postID: String, currentUserID: String) {
        let decrement: Int64 = -1
        let data: [String: Any] = [
            DatabaseHelperField.likeCount: FieldValue.increment(decrement)
        ]
        postsCollection.document(postID).updateData(data)
    }

    func commentPostCount(postID: String, currentUserID: String) async throws {
        _ = try await downloadComments(postID: postID)
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
