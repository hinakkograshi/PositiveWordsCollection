//
//  ContentView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/17.
//

import SwiftUI

struct ContentView: View {
    @State private var showSignInView: Bool = false
    var body: some View {
        TabView {
            NavigationStack {
                HomeView(posts: PostArrayObject())
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            NavigationStack {
                SignInProfileView()
            }
            .tabItem {
                Image(systemName: "bell.fill")
                Text("Notice")
            }
            NavigationStack {
                ProfileView(isMyProfile: true, profileDisplayName: "userName", profileUserID: "userID")
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
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil ? true : false
//            try? AuthenticationManager.shared.getProvider()
        }
        .fullScreenCover(isPresented: $showSignInView, content: {
            AuthenticationView(showSignInView: $showSignInView)
        })
//        if showSignInView == false, 
    }
}

#Preview {
    ContentView()
}
