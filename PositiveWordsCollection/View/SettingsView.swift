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
    @State var showDeleteAccountError = false
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @Environment(\.openURL) private var openURL
    //    @Binding var showSignInView: Bool
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button("利用規約") {
                        if let url = URL(string: "https://royal-wisteria-cf4.notion.site/52a618b0823648db89f024703733045e") {
                            openURL(url)
                        }
                    }
                    .foregroundStyle(.black)
                    Button("プライバシーポリシー") {
                        if let url = URL(string: "https://www.notion.so/13be1dd4865f4bdf918b6c3b1a7e3971") {
                            openURL(url)
                        }
                    }
                    .foregroundStyle(.black)
                } header: {
                    Text("その他")
                }

                Section {
                    Button(role: .destructive) {
                        viewModel.didTapLogOutButton()
                    } label: {
                        Text("ログアウト")
                    }
                    Button(role: .destructive) {
                        showUserDelete = true
                    } label: {
                        Text("アカウントの削除")
                    }
                } header: {
                    Text("アカウント")
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.colorBeige, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .alert(isPresented: $showDeleteAccountError, content: {
            return Alert(title: Text("アカウントの削除に失敗しました"))
        })
        .fullScreenCover(isPresented: $viewModel.showSignInView, content: {
            AuthenticationView(showSignInView: $viewModel.showSignInView)
        })
        .alert("アカウント削除", isPresented: $showUserDelete, actions: {
            Button("アカウント削除", role: .destructive) {
                Task {
                    do {
                        guard let userID = currentUserID else { return }
                        try await DeleteService.instance.deleteAccount(userID: userID)
                        viewModel.showSignInView = true
                    } catch {
                        print("deleteAccount Error")
                        showDeleteAccountError = true
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
