//
//  AuthService.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct CurrentUserDefaults {
    static let displayName = "display_name"
    static let bio = "bio"
    static let userID = "user_id"
}
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

    func asyncLogInUserToFirebase(credential: AuthCredential) async throws -> LogInUser {
        return try await withCheckedThrowingContinuation { continuation in
            logInUserToFirebase(credential: credential) { providerID, isError, isNewUser, userID in
                continuation.resume(returning: LogInUser(providerID: providerID, isError: isError, isNewUser: isNewUser, userID: userID))
            }
        }
    }

    func logInUserToFirebase(credential: AuthCredential, handler: @escaping (_ providerID: String?, _ isError: Bool, _ isNewUser: Bool?, _ userID: String?) -> ()) {
        Auth.auth().signIn(with: credential) { result, error in
            if error != nil {

                print("Errir login in to Firebase\(error)")
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
                    handler(providerID, false, false, userID)
                } else {
                    handler(providerID, false, true, nil)
                }
            }
        }
    }

    private func checkIfUserExistsDatabase(providerID: String, handler: @escaping(_ existingUserID: String?) -> ()) {
        userCollection.whereField(DatabaseUserField.providerID, isEqualTo: providerID).getDocuments { querySnapshot, error in
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

    func logInUserToApp(userID: String) async throws {
        let (returnedName, returnBio) = try await getUserInfo(userID: userID)
        DispatchQueue.main.asyncAfterUnsafe(deadline: .now() + 1.0) {
            UserDefaults.standard.set(userID, forKey: CurrentUserDefaults.userID)
            UserDefaults.standard.set(returnedName, forKey: CurrentUserDefaults.displayName)
            UserDefaults.standard.set(returnBio, forKey: CurrentUserDefaults.bio)
        }
    }

    func createNewUserInDatabase(name: String, email: String, providerID: String, provider: String, profileImage: UIImage, bio: String) async throws {
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
    }

    func getUserInfo(userID: String) async throws -> (name: String, bio: String) {
        let snapshot = try await userDocument(userId: userID).getDocument()
        guard let name = snapshot.get(DatabaseUserField.displayName) as? String, let bio = snapshot.get(DatabaseUserField.bio) as? String else { throw URLError(.cannotFindHost)}
        return (name, bio)
    }
}
