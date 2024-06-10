//
//  AuthService.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

struct LogInUser {
    let providerID: String?
    let isError: Bool
    let isNewUser: Bool?
    let userID: String?
}

class AuthService {
    static let instance = AuthService()
    private let userCollection = Firestore.firestore().collection("users")
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    // サブコレクションの削除が完了した後に親ドキュメントも削除する
    func deleteUser(userID: String) async throws {
        // UserDefault削除
        // All UserDefault Delete
        let defaultDictionary = UserDefaults.standard.dictionaryRepresentation()
        print(defaultDictionary)
        defaultDictionary.keys.forEach { key in
            UserDefaults.standard.removeObject(forKey: key)
        }
        print("🟥deleteデータ\(defaultDictionary)")
        // posts Collection of userID
        let postOfUserSnapshot = try await Firestore.firestore().collection("posts").whereField(DatabasePostField.userID, isEqualTo: userID).getDocuments()
        let usersAccountSnapshot = try await Firestore.firestore().collection("users").whereField(DatabasePostField.userID, isEqualTo: userID).getDocuments()
        for usersDocument in usersAccountSnapshot.documents {
            try await usersDocument.reference.delete()
        }
        print("🟥snapshotデータ\(postOfUserSnapshot)")
        let docData = postOfUserSnapshot.documents
        print("🟥docData\(docData)")
        let storageRef = Storage.storage().reference()

        for document in postOfUserSnapshot.documents {
            let postID = document.documentID

            // SubCollection
            let subCollection = db.collection("posts").document("\(postID)").collection("comments")
            let subSnapshot = try await subCollection.getDocuments()
            for subdocument in subSnapshot.documents {
                try await subdocument.reference.delete()
            }
            print("⭐️これPostID\(document.documentID)⭐️")
            // Postの全削除
            try await db.collection("posts").document("\(postID)").delete()
//            try await document.reference.delete()
            let postIDRef = storageRef.child("posts").child("\(postID)").child("1")
            try await postIDRef.delete()
            let userIDRef = storageRef.child("users").child("\(userID)").child("profile")
            try await userIDRef.delete()
        }
        // users Collection Delete
        try await userCollection.document(userID).delete()
        // Authアカウント削除
        guard let user = Auth.auth().currentUser else {throw URLError(.badURL)}
        try await user.delete()
    }

    func asyncLogInUserToFirebase(credential: AuthCredential) async throws -> LogInUser {
        return try await withCheckedThrowingContinuation { continuation in
            logInUserToFirebase(credential: credential) { providerID, isError, isNewUser, userID in
                continuation.resume(returning: LogInUser(providerID: providerID, isError: isError, isNewUser: isNewUser, userID: userID))
            }
        }
    }

    func logInUserToFirebase(credential: AuthCredential, handler: @escaping (_ providerID: String?, _ isError: Bool, _ isNewUser: Bool?, _ userID: String?) -> Void) {
        Auth.auth().signIn(with: credential) { result, error in
            if error != nil {
                print("Error login in to Firebase\(error)")
                handler(nil, true, nil, nil)
                return
            }
            guard let providerID = result?.user.uid else {
                // nilの場合
                print("Error getting provider ID")
                handler(nil, true, nil, nil)
                return
            }

            self.checkIfUserExistsDatabase(providerID: providerID) { returnedUserID in
                if let userID  = returnedUserID {
                    // Userが存在
                    handler(providerID, false, false, userID)
                } else {
                    // Userが存在しない
                    handler(providerID, false, true, nil)
                }
            }
        }
    }

    private func checkIfUserExistsDatabase(providerID: String, handler: @escaping(_ existingUserID: String?) -> Void) {
        userCollection.whereField(DatabaseUserField.providerID, isEqualTo: providerID).getDocuments { querySnapshot, _ in
            if let snapshot = querySnapshot, snapshot.count > 0, let document = snapshot.documents.first {
                // documentIDであるusrID
                let existingUserID = document.documentID
                handler(existingUserID)
                return
            } else {
                handler(nil)
                return
            }
        }
    }
// UserDefault保存
    func logInUserToApp(userID: String) async throws {
        do {
            // get user ID
            let (returnedName, returnBio) = try await getUserInfo(userID: userID)
            // UserDefault保存
                UserDefaults.standard.set(userID, forKey: CurrentUserDefaults.userID)
                UserDefaults.standard.set(returnedName, forKey: CurrentUserDefaults.displayName)
                UserDefaults.standard.set(returnBio, forKey: CurrentUserDefaults.bio)
        } catch {
            print("Error getting lohInUser Info")
            throw AsyncError(message: "Error getting lohInUser Info")
        }
    }

    func getUserInfo(userID: String) async throws -> (name: String, bio: String) {
        let snapshot = try await userDocument(userId: userID).getDocument()
        guard let name = snapshot.get(DatabaseUserField.displayName) as? String, 
                let bio = snapshot.get(DatabaseUserField.bio) as? String else { throw URLError(.cannotFindHost)}
        print("Success getting user info")
        return (name, bio)
    }

    func createNewUserInDatabase(name: String, email: String, providerID: String, provider: String, profileImage: UIImage, bio: String) async throws -> (String?) {
        // document作成
        let document = userCollection.document()
        let userID = document.documentID
        // Upload profile image to Storage
        do {
            try await ImageManager.instance.uploadProfileImage(userID: userID, image: profileImage)
        } catch {
            print("creteNewUserDBError \(error)")
        }

        // Upload ProfileData to Firestore
        let userData: [String: Any] = [
            DatabaseUserField.displayName: name,
            DatabaseUserField.email: email,
            DatabaseUserField.providerID: providerID,
            DatabaseUserField.provider: provider,
            DatabaseUserField.userID: userID,
            DatabaseUserField.bio: bio,
            DatabaseUserField.dateCreated: FieldValue.serverTimestamp()
        ]
        // documentにデータを追加
        try await document.setData(userData)
        return userID
    }

    func updateUserProfileText(userID: String, displayName: String, bio: String) async throws {
                let data: [String: Any] = [
                    DatabaseUserField.displayName: displayName,
                    DatabaseUserField.bio: bio
                ]
        try await userCollection.document(userID).updateData(data)

    }
}
