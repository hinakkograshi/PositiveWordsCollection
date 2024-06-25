//
//  AuthService.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct LogInUser {
    let providerID: String?
    let isError: Bool
    let isNewUser: Bool?
    let userID: String?
}

struct DatabaseUser: Codable {
    let userId: String
    let displayName: String
    let email: String
    let providerId: String
    let provider: String
    let bio: String
    let dateCreated: Date?
}

class AuthService {
    static let instance = AuthService()
    private let userCollection = Firestore.firestore().collection("users")
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }

    func createUserId() -> String {
        let document = userCollection.document()
        let userID = document.documentID
        return userID
    }

    // キャメルケースをスネークケースにする
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    // Decode
    func getUserInfo(userID: String) async throws -> DatabaseUser {
        try await userDocument(userId: userID).getDocument(as: DatabaseUser.self, decoder: decoder)
    }
    // Encode
    func createNewUserInDatabase(user: DatabaseUser, profileImage: UIImage) async throws {
        // Upload profile image to Storage
        do {
            try await ImageManager.instance.uploadProfileImage(userID: user.userId, image: profileImage)
        } catch {
            print("creteNewUserDBError \(error)")
        }
        // documentにデータを追加
        try userDocument(userId: user.userId).setData(from: user, encoder: encoder)
    }
    // Update Dictionary
    func updateUserProfileText(userID: String, displayName: String, bio: String) async throws {
        let data: [String: Any] = [
            DatabaseUserField.displayName: displayName,
            DatabaseUserField.bio: bio
        ]
        try await userCollection.document(userID).updateData(data)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func userAcountDelete() async throws {
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
                print("😭\(error!)")
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
            let user = try await getUserInfo(userID: userID)
            // UserDefault保存
            UserDefaults.standard.set(userID, forKey: CurrentUserDefaults.userID)
            UserDefaults.standard.set(user.displayName, forKey: CurrentUserDefaults.displayName)
            UserDefaults.standard.set(user.bio, forKey: CurrentUserDefaults.bio)
        } catch {
            print("Error getting lohInUser Info")
            throw AsyncError(message: "Error getting lohInUser Info")
        }
    }
}
