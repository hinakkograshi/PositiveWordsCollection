//
//  HomeView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/19.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var posts: PostArrayObject
    @State var showCreatePostView = false
    @State var firstAppear = true
    @State var isLastPost = false
    @AppStorage("hiddenPostIDs") var hiddenPostIDs: [String] = []
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                ForEach(posts.dataArray) { post in
                    PostView(post: post, posts: posts, headerIsActive: false, comentIsActive: false)
                    if post == posts.dataArray.last, isLastPost == false {
                        ProgressView()
                            .onAppear {
                                Task {
                                    isLastPost = await posts.refreshHome(hiddenPostIDs: hiddenPostIDs)
                                }
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
            content: {
                CreatePostView(posts: posts)
            })
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.colorBeige, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)

        .onAppear {
            print("🟩HomeView表示されました")
            if firstAppear == true {
                print("🟩初めて")
                Task {
                    await posts.refreshHome(hiddenPostIDs: hiddenPostIDs)
                }
            }
        }
    }
}

#Preview {
    HomeView(posts: PostArrayObject())
}
