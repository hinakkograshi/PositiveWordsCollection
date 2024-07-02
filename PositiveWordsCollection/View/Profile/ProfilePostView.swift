//
//  PostGridView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/06/08.
//

import SwiftUI

struct ProfilePostView: View {
    @ObservedObject var posts: PostArrayObject
    @State var isLastPost = false
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                ForEach(posts.userPostArray) { post in
                    PostView(post: post, posts: posts, headerIsActive: true, comentIsActive: false)
                    if post == posts.userPostArray.last, isLastPost == false {
                        ProgressView()
                            .onAppear {
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

#Preview {
    ProfilePostView(posts: PostArrayObject())
}
