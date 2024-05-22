//
//  VM.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/18.
//

import Foundation
import UIKit
import FirebaseAuth
import AuthenticationServices

enum AuthProviderOption: String {
    case google = "google.com"
    case apple = "apple.com"
}

final class AuthenticationManager {
    // シングルトン
    static let shared = AuthenticationManager()
    private init() { }

    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            print("ログインusernil")
            throw URLError(.badServerResponse)
        }
        print("ログインuser:\(user)")
        print("ログインuser:\(AuthDataResultModel(user: user))")
        return AuthDataResultModel(user: user)
    }
// delete
//    func getProvider() throws {
//        guard let providerData = Auth.auth().currentUser?.providerData else {
//            throw URLError(.badServerResponse)
//        }
//        for provider in providerData {
//            // google.com
//            print(provider.providerID)
//        }
//    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        try await user.delete()
    }
}

extension AuthenticationManager {

    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }

    @discardableResult
    func signInWithApple(tokens: SignInAppleResult) async throws -> AuthDataResultModel {

        let credential = OAuthProvider.appleCredential(withIDToken: tokens.token,
                                                       rawNonce: tokens.nonce,
                                                       fullName: tokens.fullName)
        return try await signIn(credential: credential)
    }

    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult =  try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
