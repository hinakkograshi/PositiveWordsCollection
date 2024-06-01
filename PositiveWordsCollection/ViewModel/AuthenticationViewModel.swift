//
//  AuthenticationViewModel.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/18.
//

import Foundation
import GoogleSignIn
import FirebaseAuth
import FirebaseCore

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
    @Published var hadSignInUser = false
    let signInAppleHelper = SignInAppleHelper()

    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let (credential, authDataResult) = try await AuthenticationManager.instance.signInWithGoogle(tokens: tokens)
        let firebaseUser = authDataResult.user
        guard let fullName = firebaseUser.displayName,
              let email = firebaseUser.email else { return }
            try await connectToFirebase(name: fullName, email: email, provider: "google", credential: credential)
    }

    func signInApple() async throws {
        let helper = SignInAppleHelper()
        let signInAppleResult = try await helper.startSignInWithAppleFlow()
        let credential = try await AuthenticationManager.instance.signInWithApple(tokens: signInAppleResult)
        var name = "Your name here"
        if let fullName = signInAppleResult.fullName {
            let formatter = PersonNameComponentsFormatter()
            name = formatter.string(from: fullName)
        }
        try await connectToFirebase(name: name, email: signInAppleResult.email, provider: "apple", credential: credential)
    }

    func connectToFirebase(name: String, email: String, provider: String, credential: AuthCredential) async throws {
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
                    print("Error getting provider ID from log in user to Firebase")
                    throw AsyncError(message: "Error getting provider ID")
//                     self.showError = true
                }
            } else {
                // userIDがすでに存在している場合
                if let userID = logInUser.userID {
                    do {
                        try await AuthService.instance.logInUserToApp(userID: userID)
                        hadSignInUser = true
//                        dismiss()
                    } catch {
                        throw AsyncError(message: "logInUserToApp Error")
//                         self.showError = true
                    }
                } else {
                    // Error
                    print("Error getting user ID from log in user to Firebase")
                    throw AsyncError(message: "Error getting user ID from log in user to Firebase")
//                     self.showError = true
                }
            }
        } else {
            // Error
            print("Error getting into from log in user to Firebase")
            throw AsyncError(message: "Error getting into from log in user to Firebase")
//            self.showError = true
        }
    }
}
