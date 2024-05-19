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

    @Published var didSignInWithApple: Bool = false
    let signInAppleHelper = SignInAppleHelper()

    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        // 返り値AuthDataResultModel
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
    }

    func signInApple() async throws {
        signInAppleHelper.startSignInWithAppleFlow { result in
            switch result {
            case .success(let signInAppleResult):
                Task {
                    do {
                        try await AuthenticationManager.shared.signInWithApple(tokens: signInAppleResult)
                        self.didSignInWithApple = true
                    } catch {
                        print("SignInAppleError")

                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
