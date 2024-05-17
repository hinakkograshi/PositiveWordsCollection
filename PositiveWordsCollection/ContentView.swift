//
//  ContentView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/17.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                Text("View1")
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
                Text("View4")
            }
            .tabItem {
                Image(systemName: "gearshape")
                Text("Feed")
            }
        }
    }
}

#Preview {
    ContentView()
}
