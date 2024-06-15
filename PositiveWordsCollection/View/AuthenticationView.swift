//
//  SignUpView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/18.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import _AuthenticationServices_SwiftUI

struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    @State var showProfileView: Bool = false
    @State var showError: Bool = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.MyTheme.iconColor.ignoresSafeArea()
            VStack(spacing: 10) {
                Text("ポジティブワード")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                Text("コレクション")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                Text("嬉しかった出来事を共有し合うSNS")
                Image("homeIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .shadow(radius: 12)
                    .font(.headline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)

                // MARK: Sign in with Google
                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .wide, state: .normal)) {
                    Task {
                        do {
                            try await viewModel.signInGoogle(dissmisAction: dismiss.callAsFunction)
                            // Success
//                            showSignInView = false
                        } catch {
                            showError = true
                            print(error)
                        }
                    }
                }
                .padding(.vertical, 10)
                // MARK: Sign in with Apple
                Button(action: {
                    Task {
                        do {
                            try await viewModel.signInApple(dissmisAction: dismiss.callAsFunction)
                            // Success
//                            showSignInView = false
                        } catch {
                            showError = true
                            print(error)
                        }
                    }
                }, label: {
                    SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                        .allowsHitTesting(false)
                })
                .frame(height: 50)
            }
            .padding()
        }

        .fullScreenCover(isPresented: $viewModel.showSignInProfileView, onDismiss: {
            dismiss()
        }, content: {
            SignInProfileView(viewModel: viewModel)
        })
        .alert(isPresented: $showError, content: {
            return Alert(title: Text("サインインに失敗しました"))
        })
    }
}

#Preview {
    @State var showSignInView = true
    return NavigationView {
        AuthenticationView(showSignInView: $showSignInView)
    }
}
