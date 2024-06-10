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
        try AuthService.instance.signOut()
            print("Success Log out")
            // All UserDefault Delete
            let defaultDictionary = UserDefaults.standard.dictionaryRepresentation()
            print(defaultDictionary)
            defaultDictionary.keys.forEach { key in
                UserDefaults.standard.removeObject(forKey: key)
            }
            print(defaultDictionary)
    }

//    func deleteAccount() async throws {
//        try await AuthService.instance.deleteUser()
//    }
}
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State var showUserDelete = false
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
//    @Binding var showSignInView: Bool
    var body: some View {
        List {
            Button("Log out") {
                viewModel.didTapLogOutButton()
            }
            Button(role: .destructive) {
                showUserDelete = true
            } label: {
                Text("Delete account")
            }
        }
        .fullScreenCover(isPresented: $viewModel.showSignInView, content: {
            AuthenticationView(showSignInView: $viewModel.showSignInView)
        })
        .alert("アカウント削除", isPresented: $showUserDelete, actions: {
            Button("アカウント削除", role: .destructive) {
                Task {
                    do {
                        guard let userID = currentUserID else { return }
                        try await AuthService.instance.deleteAccount(userID: userID)
                        viewModel.showSignInView = true
                    } catch {
                        print("deleteAccount: \(error)")
                    }
                }
            }
            Button("キャンセル", role: .cancel) {
                showUserDelete = false
            }
        }, message: {
            Text("アカウントを削除するとデータを復活できません。")
        })
        .alert(isPresented: $viewModel.showSignOutError, content: {
            return Alert(title: Text("ログアウトに失敗しました。"))
        })
    }
}

#Preview {
    return SettingsView()
}
