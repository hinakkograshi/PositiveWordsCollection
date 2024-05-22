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
                Text("View2")
            }
            .tabItem {
                Image(systemName: "bell.fill")
                Text("Notice")
            }
            NavigationStack {
                Text("View3")
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            NavigationStack {
                SettingsView(showSignInView: $showSignInView)
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
    }
}

#Preview {
    ContentView()
}
