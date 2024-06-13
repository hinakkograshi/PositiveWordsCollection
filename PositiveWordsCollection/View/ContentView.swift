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

    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @AppStorage(CurrentUserDefaults.displayName) var currentUserName: String?
    // ここで全部の投稿取得
    @StateObject private var homePosts = PostArrayObject()
    var body: some View {
        TabView {
            NavigationStack {
                HomeView(posts: homePosts)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            NavigationStack {
                if let userID = currentUserID, let displayName = currentUserName {
                    ProfileView(
                        isMyProfile: true,
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
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape")
                Text("Settings")
            }
        }
        .onAppear {
            self.showSignInView = currentUserID == nil ? true : false
            //            let authUser = try? AuthenticationManager.instance.getAuthenticatedUser()
            //            self.showSignInView = authUser == nil ? true : false
        }
        .fullScreenCover(isPresented: $showSignInView, content: {
            AuthenticationView(showSignInView: $showSignInView)
        })

    }
}

#Preview {
    ContentView()
}
