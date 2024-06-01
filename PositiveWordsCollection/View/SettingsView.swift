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
    func signOut() throws {
        try AuthenticationManager.instance.signOut()
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
                Task {
                    do {
                        try viewModel.signOut()
                        viewModel.showSignInView = true
                    } catch {
                        print(error)
                    }
                }
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
    }
}

#Preview {
    return SettingsView()
}
