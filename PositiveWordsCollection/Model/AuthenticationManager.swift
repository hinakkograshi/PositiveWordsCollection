//
//  VM.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/18.
//

import Foundation
import UIKit
import FirebaseAuth
struct AuthDataResultModel {
    let uid: String
    // 別の方法いらない
    let email: String?
    let photoURL: String?
// 構造体があり、別のところから初期化する
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoURL = user.photoURL?.absoluteString
    }
}
final class AuthenticationManager {
    // シングルトン
    static let instance = AuthenticationManager()

    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> (AuthCredential, AuthDataResult) {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        let authDataResult = try await signIn(credential: credential)
        return (credential, authDataResult)
    }

//    func signInWithApple(tokens: SignInAppleResult) async throws -> (OAuthCredential) {
//
//        let credential = OAuthProvider.appleCredential(withIDToken: tokens.token,
//                                                       rawNonce: tokens.nonce,
//                                                       fullName: tokens.fullName)
//        let authDataResult = try await signIn(credential: credential)
//        return credential
//    }

    func signIn(credential: AuthCredential) async throws -> AuthDataResult {
        let authDataResult =  try await Auth.auth().signIn(with: credential)
        return authDataResult
    }
}
