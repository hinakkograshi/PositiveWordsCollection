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
    @StateObject var posts = PostArrayObject()

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(posts: posts)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            NavigationStack {
                if let userID = currentUserID, let displayName = currentDisplayName {
                    ProfileView(isMyProfile: true, posts: posts, profileDisplayName: displayName, profileUserID: userID)
                }
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
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
        .onAppear {
            self.showSignInView = currentUserID == nil ? true : false
        }

        .fullScreenCover(isPresented: $showSignInView,
                         onDismiss: {
            if let userID = currentUserID {
                Task {
                    _ = await posts.refreshHome(hiddenPostIDs: hiddenPostIDs, myUserID: userID)
                }
            }
        },
                         content: {
            AuthenticationView(showSignInView: $showSignInView)
        })
    }
}

#Preview {
    ContentView()
}
