//
//  AuthenticationViewModel.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/18.
//

import Foundation
import UIKit
import GoogleSignIn
import FirebaseAuth

@MainActor
final class AuthenticationViewModel: ObservableObject {

    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        // 返り値AuthDataResultModel
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
    }
}
