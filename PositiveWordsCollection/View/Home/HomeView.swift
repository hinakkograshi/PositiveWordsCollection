//
//  HomeView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/19.
//

import SwiftUI

struct HomeView: View {
    @StateObject var posts: PostArrayObject
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                ForEach(posts.dataArray, id: \.self) { post in
                    PostCell(post: post)
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button(action: {

            }, label: {
                Image(systemName: "plus")
                    .foregroundStyle(.white)
                    .padding(20)
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 100))
            })
            .padding(10)
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    HomeView(posts: PostArrayObject())
}
