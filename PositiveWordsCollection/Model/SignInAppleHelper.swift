//
//  SignInAppleHelper.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/19.
//

import Foundation
import SwiftUI
import CryptoKit
import AuthenticationServices

// UIKitのViewをSwiftUIへ
struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    func makeUIView(context: Context) -> some ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(authorizationButtonType: type, authorizationButtonStyle: style)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {

    }
}

struct SignInAppleResult {
    let token: String
    let nonce: String
    let fullName: PersonNameComponents?
}

@MainActor
final class SignInAppleHelper: NSObject {

    private var currentNonce: String?
    private var completionHandler: ((Result<SignInAppleResult, Error>) -> Void)? = nil

    func startSignInWithAppleFlow() async throws -> SignInAppleResult {
        try await withCheckedThrowingContinuation { continuation in
            self.startSignInWithAppleFlow { result in
                switch result {
                case .success(let signInAppleResult):
                    continuation.resume(returning: signInAppleResult)
                    return
                case .failure(let error):
                    continuation.resume(throwing: error)
                    return
                }
            }
        }
    }

    func startSignInWithAppleFlow(completion: @escaping (Result<SignInAppleResult, Error>) -> Void) {
        guard let topVC = Utilities.shared.topViewController() else {
            completion(.failure(URLError(.badURL)))
            return
        }
      let nonce = randomNonceString()
      currentNonce = nonce
        completionHandler = completion
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = topVC
      authorizationController.performRequests()
    }

    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

extension SignInAppleHelper: ASAuthorizationControllerDelegate {

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
      guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let appleIDToken = appleIDCredential.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8),
            let nonce = currentNonce else {
          completionHandler?(.failure(URLError(.badServerResponse)))
          return
      }
      let result = SignInAppleResult(token: idTokenString, nonce: nonce, fullName: appleIDCredential.fullName)
      completionHandler?(.success(result))
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
      completionHandler?(.failure(URLError(.cannotFindHost)))
  }

}

extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        self.view.window!
    }
}
