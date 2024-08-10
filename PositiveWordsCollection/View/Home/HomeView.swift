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
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                ForEach(posts.dataArray) { post in
                    PostView(post: post, posts: posts, headerIsActive: false, comentIsActive: false)
                    if post == posts.dataArray.last, isLastPost == false {
                        ProgressView()
                            .onAppear {
                                Task {
                                    if let myUserID = currentUserID {
                                        isLastPost = await posts.refreshHome(hiddenPostIDs: hiddenPostIDs, myUserID: myUserID)
                                    }
                                }
                            }
                    }
                }
            }
        }
        .overlay {
            if posts.loadingState.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding()
                    .tint(Color.white)
                    .background(Color.gray)
                    .cornerRadius(8)
                    .scaleEffect(1.2)
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
            if firstAppear == true {
                Task {
                    firstAppear = false
                    if let myUserID = currentUserID {
                        await posts.refreshHomeFirst(hiddenPostIDs: hiddenPostIDs, myUserID: myUserID)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView(posts: PostArrayObject())
}
