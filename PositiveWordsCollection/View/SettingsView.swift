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
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = SettingsViewModel()
    @State var showUserDelete = false
    @State var showDeleteAccountError = false
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @Environment(\.openURL) private var openURL
    @State var showUserLogOut = false
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        if let url = URL(string: "https://royal-wisteria-cf4.notion.site/52a618b0823648db89f024703733045e") {
                            openURL(url)
                        }
                    } label: {
                        Text("利用規約")
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                    }
                    .foregroundStyle(.black)

                    Button {
                        if let url = URL(string: "https://www.notion.so/13be1dd4865f4bdf918b6c3b1a7e3971") {
                            openURL(url)
                        }
                    } label: {
                        Text("プライバシーポリシー")
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                    }
                    .foregroundStyle(.black)

                    Button {
                        if let url = URL(string: "https://forms.gle/3wn7dAvNAaciAwQj9") {
                            openURL(url)
                        }
                    } label: {
                        Text("お問い合わせ")
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                    }
                    .foregroundStyle(.black)
                } header: {
                    Text("その他")
                }

                Section {
                    Button(role: .destructive) {
                        showUserLogOut = true
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
            .toolbarBackground(colorScheme == .light ? Color.MyTheme.beigeColor : Color.orange
                               , for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .alert(isPresented: $showDeleteAccountError) {
            Alert(title: Text("アカウントの削除に失敗しました"))
        }
        .fullScreenCover(isPresented: $viewModel.showSignInView) {
            AuthenticationView(showSignInView: $viewModel.showSignInView)
        }
        .alert("ログアウト", isPresented: $showUserLogOut, actions: {
            Button("ログアウト", role: .destructive) {
                viewModel.didTapLogOutButton()
                viewModel.showSignInView = true
            }
            Button("キャンセル", role: .cancel) {
                showUserLogOut = false
            }
        }, message: {
            Text("ログアウトしますか？")
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
        .alert(isPresented: $viewModel.showSignOutError) {
            Alert(title: Text("ログアウトに失敗しました。"))
        }
    }
}

#Preview {
    SettingsView()
}
