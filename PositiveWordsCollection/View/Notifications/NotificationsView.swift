//
//  NotificationsView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/09/14.
//

import SwiftUI

struct NotificationsView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                ForEach(1..<8) { post in
                    NotificationsCell()
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.colorBeige, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NotificationsView()
}
