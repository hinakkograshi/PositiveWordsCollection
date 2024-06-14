//
//  PostGridView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/06/08.
//

import SwiftUI

struct ProfilePostView: View {
    @ObservedObject var posts: PostArrayObject
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                ForEach(posts.dataArray, id: \.self) { post in
                    PostView(post: post, posts: posts, headerIsActive: true, deletedDataState: .myUserLoading, comentIsActive: false)
                }
            }
        }
    }
}

#Preview {
    ProfilePostView(posts: PostArrayObject())
}
