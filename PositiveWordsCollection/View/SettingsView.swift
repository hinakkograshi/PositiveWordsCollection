//
//  SettingsView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/19.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var showSignInView = false
    @Published var showSignOutError = false

    func didTapLogOutButton() {
        do {
            try signOut()
            showSignInView = true
        } catch {
            print("log out Error")
            showSignOutError = true
        }
    }

    private func signOut() throws {
            try AuthenticationManager.instance.signOut()
            print("Success Log out")
            // All UserDefault Delete
            let defaultDictionary = UserDefaults.standard.dictionaryRepresentation()
            print(defaultDictionary)
            defaultDictionary.keys.forEach { key in
                UserDefaults.standard.removeObject(forKey: key)
            }
            print(defaultDictionary)
    }

    func deleteAccount() async throws {
        try await AuthenticationManager.instance.deleteUser()
    }
}
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
//    @Binding var showSignInView: Bool
    var body: some View {
        List {
            Button("Log out") {
                viewModel.didTapLogOutButton()
            }
            Button(role: .destructive) {
                Task {
                    do {
                        try await viewModel.deleteAccount()
                        viewModel.showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Delete account")
            }
        }
        .fullScreenCover(isPresented: $viewModel.showSignInView, content: {
            AuthenticationView(showSignInView: $viewModel.showSignInView)
        })
        .alert(isPresented: $viewModel.showSignOutError, content: {
            return Alert(title: Text("ログアウトに失敗しました。"))
        })
    }
}

#Preview {
    return SettingsView()
}
