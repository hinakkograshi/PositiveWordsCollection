//
//  HomeView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/19.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var posts = PostArrayObject()
    @State var showCreatePostView = false
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                ForEach(posts.dataArray) { post in
                    PostView(post: post, posts: posts, headerIsActive: false, deletedDataState: .allUserLoading, comentIsActive: false)
                    if post == posts.dataArray.last {
                        ProgressView()
                            .onAppear {
                                posts.refreshHome()
                            }
                    }
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                showCreatePostView.toggle()
            }, label: {
                Image(systemName: "plus")
                    .foregroundStyle(.white)
                    .padding(20)
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 100))
            })
            .padding(10)
        }
        .sheet(
            isPresented: $showCreatePostView,
            onDismiss: {
                  // 🟥 二重
//                   posts.refreshHome()
                posts.refreshFirst()

            },
            content: {
            CreatePostView()
        })
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.colorBeige, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)

        .onAppear {
            print("🟩HomeView表示されました")
            Task {
                posts.refreshFirst()
            }
        }
    }
}

#Preview {
    HomeView()
}
