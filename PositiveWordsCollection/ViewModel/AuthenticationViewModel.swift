//
//  AuthenticationViewModel.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/18.
//

import Foundation
import GoogleSignIn
import FirebaseAuth

struct AsyncError: Error {
    let message: String
}

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var displayName: String = ""
    @Published var email: String = ""
    @Published var providerID: String = ""
    @Published var provider: String = ""
    @Published var bio: String = ""
    @Published var showSignInProfileView: Bool = false
    @Published var showError = false

    func signInGoogle(dissmisAction: () -> Void) async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let (credential, authDataResult) = try await helper.signInWithGoogle(tokens: tokens)
        let firebaseUser = authDataResult.user
        guard let fullName = firebaseUser.displayName,
              let email = firebaseUser.email else { return }
        try await connectToFirebase(name: fullName, email: email, provider: "google", credential: credential, completion: dissmisAction)
    }

    func signInApple(dissmisAction: () -> Void) async throws {
        let helper = SignInAppleHelper()
        let signInAppleResult = try await helper.startSignInWithAppleFlow()
        try await connectToFirebase(name: signInAppleResult.fullName, email: signInAppleResult.email, provider: "apple", credential: signInAppleResult.credential, completion: dissmisAction)
    }

    private func connectToFirebase(name: String, email: String, provider: String, credential: AuthCredential, completion: () -> Void) async throws {
        let logInUser = try await AuthService.instance.asyncLogInUserToFirebase(credential: credential)
        if let newUser = logInUser.isNewUser {
            if newUser {
                // NEW USER
                if let providerID = logInUser.providerID, !logInUser.isError {
                    self.displayName = name
                    self.email = email
                    self.providerID = providerID
                    self.provider = provider
                    self.showSignInProfileView = true
                } else {
                    self.showError = true
                    print("Error getting provider ID from log in user to Firebase")
                    throw AsyncError(message: "Error getting provider ID")
                }
            } else {
                // Exist User
                if let userID = logInUser.userID {
                    do {
                        try await AuthService.instance.logInUserToApp(userID: userID)
                        completion()
                    } catch {
                        self.showError = true
                        throw AsyncError(message: "logInUserToApp Error")
                    }
                } else {
                    // Error
                    self.showError = true
                    print("Error getting user ID from log in user to Firebase")
                    throw AsyncError(message: "Error getting user ID from log in user to Firebase")
                }
            }
        } else {
            // Error
            self.showError = true
            print("Error getting into from log in user to Firebase")
            throw AsyncError(message: "Error getting into from log in user to Firebase")
        }
    }
}
