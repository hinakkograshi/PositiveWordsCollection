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
//    @Environment(\.presentationMode) var presentationMode
//    @State var displayNama: String = ""
//    @State var email: String = ""
//    @State var providerID: String = ""
//    @State var provider: String = ""
//    @State var showNameOnboarding: Bool = false
//    @State var showError: Bool = false
    var body: some View {
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
            Image(systemName: "person")
                .resizable()
                .scaledToFit()
                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .shadow(radius: 12)
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            //                .foregroundStyle(Color.MyTheme.purpleColor)

            // MARK: Sign in with Google
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .wide, state: .normal)) {
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        // Success
                        showSignInView = false
                    } catch {
                        print(error)
                    }
                }
            }
            // MARK: Sign in with Apple
            Button(action: {
                Task {
                    do {
                        try await viewModel.signInApple()
                        showSignInView = false
                    } catch {
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
}

#Preview {
    @State var showSignInView = true
    return NavigationView {
        AuthenticationView(showSignInView: $showSignInView)
    }
}
