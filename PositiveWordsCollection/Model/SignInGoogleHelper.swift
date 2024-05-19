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
//    let name: String?
//    let email: String?
}
final class SignInGoogleHelper {
    @MainActor
    func signIn() async throws -> GoogleSignInResultModel {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first, let rootViewController = window.rootViewController else {
            throw URLError(.cannotFindHost)
      }
        let gidSignInReault = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

        guard let idToken = gidSignInReault.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let accessToken = gidSignInReault.user.accessToken.tokenString

        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        return tokens
    }
}
