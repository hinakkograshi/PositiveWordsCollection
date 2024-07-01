//
//  PostGridView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/06/08.
//

import SwiftUI

struct ProfilePostView: View {
    @ObservedObject var posts: PostArrayObject
    @State var lastPostId = ""
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                ForEach(posts.dataArray) { post in
                    PostView(post: post, posts: posts, headerIsActive: true, comentIsActive: false)
                    if post == posts.dataArray.last {
//                        if lastPostId != post {
//                            lastPostId = post
                            ProgressView()
                                .onAppear {
                                    posts.refreshUserPost(userID: post.userID)
                                }
//                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ProfilePostView(posts: PostArrayObject())
}
