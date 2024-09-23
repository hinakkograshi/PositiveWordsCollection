//
//  DeleteService.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/06/20.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseStorage

class DeleteService {
    static let instance = DeleteService()

    func postDelete(postID: String) async throws {
        // SubCollection Delete
        await postsSubCollectionDelete(postID: postID)
        await likedBySubCollectionDelete(postID: postID)
        // PostCollection Delete
        try await Firestore.firestore().collection("posts").document(postID).delete()
        // Storage削除
        await postsStorageDelete(postID: postID)
    }
    // サブコレクションの削除が完了した後に親ドキュメントも削除する
    func deleteAccount(userID: String) async throws {
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
        do {
            try await Firestore.firestore().collection("users").document(userID).delete()
        } catch {
            print("users Collection Delete Error:\(error)")
        }
        // Authアカウント削除
        do {
            try await AuthService.instance.userAcountDelete()
        } catch {
            print("Authアカウント削除Error:\(error)")
        }
    }

    private func postAllDelete(userID: String) async throws {
        // posts Collection of userID
        let postOfUserSnapshot = try await Firestore.firestore().collection("posts").whereField(DatabaseHelperField.userID, isEqualTo: userID).getDocuments()

        for document in postOfUserSnapshot.documents {
            let postID = document.documentID
            // SubCollection Delete
            await postsSubCollectionDelete(postID: postID)
            await likedBySubCollectionDelete(postID: postID)
            // PostCollection Delete
            try await Firestore.firestore().collection("posts").document(postID).delete()
            // Storage削除
            await postsStorageDelete(postID: postID)
        }
    }

    private func likedBySubCollectionDelete(postID: String) async {
        let subCollection = Firestore.firestore().collection("posts").document(postID).collection(DatabaseHelperField.likedBy)
        do {
            let subSnapshot = try await subCollection.getDocuments()
            for subdocument in subSnapshot.documents {
                try await subdocument.reference.delete()
            }
        } catch {
            print("likedBySubCollectionDelete Error")
        }
    }

    private func postsSubCollectionDelete(postID: String) async {
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
            print("🟥userStorageDelete Error")
        }
    }

    private func deleteUserCollection(userID: String) async {
        do {
            let usersAccountSnapshot = try await Firestore.firestore().collection("users").whereField(DatabaseHelperField.userID, isEqualTo: userID).getDocuments()
            for usersDocument in usersAccountSnapshot.documents {
                try await usersDocument.reference.delete()
            }
        } catch {
            print("🟥deleteUserCollection Error")
        }
    }
}
