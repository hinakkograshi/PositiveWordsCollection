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
    private init() { }
    //

    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            print("ログインusernil")
            throw URLError(.badServerResponse)
        }
        print("ログインuser:\(user)")
        print("ログインuser:\(AuthDataResultModel(user: user))")
        return AuthDataResultModel(user: user)
    }

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
    
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> (AuthCredential, AuthDataResult) {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        let authDataResult = try await signIn(credential: credential)
        return (credential, authDataResult)
    }
    
    func signInWithApple(tokens: SignInAppleResult) async throws -> (OAuthCredential) {

        let credential = OAuthProvider.appleCredential(withIDToken: tokens.token,
                                                       rawNonce: tokens.nonce,
                                                       fullName: tokens.fullName)
        let authDataResult = try await signIn(credential: credential)
        return credential
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResult {
        let authDataResult =  try await Auth.auth().signIn(with: credential)
        return authDataResult
    }
}
    // struct DBUser: Codable {
    //    let userID: String
    //    let displayName: String?
    //    let email: String?
    //    let providerID: String?
    //    let provider: String?
    //    let bio: String?
    //    let dateCreated: Date?
    // }
//    private let encoder: Firestore.Encoder = {
//        let encoder = Firestore.Encoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
//        return encoder
//    }()
//
//    private let decoder: Firestore.Decoder = {
//        let decoder = Firestore.Decoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//        return decoder
//    }()
//
//    func createNewUser(user: DBUser) async throws {
//        try userDocument(userId: user.userID).setData(from: user, merge: false, encoder: encoder)
//    }
//
//    func getUserInfo(userId: String) async throws -> DBUser {
//        try await userDocument(userId: userId).getDocument(as: DBUser.self, decoder: decoder)
//    }

//    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
//        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
//        return try await signIn(credential: credential)
//    }
//
//    func signInWithApple(tokens: SignInAppleResult) async throws -> AuthDataResultModel {
//
//        let credential = OAuthProvider.appleCredential(withIDToken: tokens.token,
//                                                       rawNonce: tokens.nonce,
//                                                       fullName: tokens.fullName)
//        return try await signIn(credential: credential)
//    }

//    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
//        let authDataResult =  try await Auth.auth().signIn(with: credential)
//        return AuthDataResultModel(user: authDataResult.user)
//    }
