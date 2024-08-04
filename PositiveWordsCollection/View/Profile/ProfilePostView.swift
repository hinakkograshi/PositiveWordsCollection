//
//  PostGridView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/06/08.
//

import SwiftUI

struct ProfilePostView: View {
    @ObservedObject var posts: PostArrayObject
    var isMyProfile: Bool
    @State var isLastPost = false
    @State var isMyLastPost = false

    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                if isMyProfile {
                    ForEach(posts.myUserPostArray) { post in
                        PostView(post: post, posts: posts, headerIsActive: true, comentIsActive: false)
                        if post == posts.myUserPostArray.last, isMyLastPost == false {
                            ProgressView()
                                .onAppear {
                                    Task {
                                        Task {
                                            isMyLastPost = await posts.refreshMyUserPost(userID: post.userID)
                                        }
                                    }
                                }
                        }
                    }
                } else {
                    ForEach(posts.userPostArray) { post in
                        PostView(post: post, posts: posts, headerIsActive: true, comentIsActive: false)
                        if post == posts.userPostArray.last, isLastPost == false {
                            ProgressView()
                                .onAppear {
                                    Task {
                                        Task {
                                            isLastPost = await posts.refreshUserPost(userID: post.userID)
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ProfilePostView(posts: PostArrayObject(), isMyProfile: true)
}
