//
//  ContentView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/17.
//

import SwiftUI

struct ContentView: View {
    @State private var showSignInView: Bool = false
    @State private var showSignInProfileView: Bool = false
    @AppStorage("hiddenPostIDs") var hiddenPostIDs: [String] = []
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @AppStorage(CurrentUserDefaults.displayName) var currentDisplayName: String?
    @AppStorage(CurrentUserDefaults.bio) var currentBio: String?
    @StateObject var posts = PostArrayObject()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if currentUserID != nil {
            TabView {
                NavigationStack {
                    HomeView(posts: posts)
                }
                .tint(colorScheme == .light ? .black : .white)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                NavigationStack {
                    if let userID = currentUserID,
                       let displayName = currentDisplayName,
                       let myBio = currentBio {
                        ProfileView(
                            isMyProfile: true,
                            posts: posts,
                            profileBio: myBio,
                            profileDisplayName: displayName,
                            profileUserID: userID
                        )
                    }
                }
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                NavigationStack {
                    NotificationsView(posts: posts)
                }
                .tint(colorScheme == .light ? .black : .white)
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Notifications")
                }
                NavigationStack {
                    SettingsView()
                }
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
            }
            .accentColor(.orange)
        } else {
            AuthenticationView(showSignInView: $showSignInView)
        }
    }
}

#Preview {
    ContentView()
}
