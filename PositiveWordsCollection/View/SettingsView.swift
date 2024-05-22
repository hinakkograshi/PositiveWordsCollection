//
//  SettingsView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/19.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }

    func deleteAccount() async throws {
        try await AuthenticationManager.shared.deleteUser()
    }
}
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    var body: some View {
        List {
            Button("Log out") {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            }
            Button(role: .destructive) {
                Task {
                    do {
                        try await viewModel.deleteAccount()
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Delete account")
            }
        }
    }
}

#Preview {
    @State var showSignInView = false
    return SettingsView(showSignInView: $showSignInView)
}
