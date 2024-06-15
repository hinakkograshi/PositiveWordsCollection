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

extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        self.view.window!
    }
}
