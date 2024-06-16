//
//  SignInGoogleHelper.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/19.
//

import Foundation
import UIKit
import GoogleSignIn
import FirebaseAuth

// 構造体を作成
struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
}

final class SignInGoogleHelper {

    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> (AuthCredential, AuthDataResult) {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        let authDataResult = try await signInGoogle(credential: credential)
        return (credential, authDataResult)
    }

    private func signInGoogle(credential: AuthCredential) async throws -> AuthDataResult {
        let authDataResult =  try await Auth.auth().signIn(with: credential)
        return authDataResult
    }

    @MainActor
    func signIn() async throws -> GoogleSignInResultModel {
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        let gidSignInReault = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)

        guard let idToken = gidSignInReault.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let accessToken = gidSignInReault.user.accessToken.tokenString

        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        return tokens
    }
}
