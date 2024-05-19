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
                Button(action: {
                    do {
                        try AuthenticationManager.shared.signOut()
                    } catch {
                        print(error)
                    }
                }, label: {
                    Text("Button")
                })
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            NavigationStack {
                Text("View3")
            }
            .tabItem {
                Image(systemName: "book.fill")
                Text("Collection")
            }
            NavigationStack {
                Text("View2")
            }
            .tabItem {
                Image(systemName: "bell.fill")
                Text("Notice")
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
        // trueであれば,AuthenticationView
        .fullScreenCover(isPresented: $showSignInView, content: {
            AuthenticationView(showSignInView: $showSignInView)
        })
    }
}

#Preview {
    ContentView()
}
