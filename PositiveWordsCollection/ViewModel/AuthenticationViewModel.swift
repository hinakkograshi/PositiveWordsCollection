//
//  AuthenticationViewModel.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/18.
//

import Foundation
import GoogleSignIn

@MainActor
final class AuthenticationViewModel: ObservableObject {

    let signInAppleHelper = SignInAppleHelper()

    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
    }

    func signInApple() async throws {
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
    }
}
