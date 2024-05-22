//
//  PostCell.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/21.
//

import SwiftUI

struct PostCell: View {
    @State var post: PostModel
    var body: some View {
        VStack {
            // header
            HStack {
                Image("hiyoko")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                Text(post.username)
                    .font(.callout)
                    .fontWeight(.medium)
                // Time
                Text("2s")
                    .foregroundStyle(.gray)
                    .font(.caption)
                // light and dark mode対応
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "ellipsis")
                    .font(.headline)
            }
            .padding(3)
            // Content
            HStack {
                // stamp Image
                Image("hiyo")
                // post caption
                Text("今日は仕事頑張った!先輩にいつも前向きに頑張っててえらいね！と言われた！\n先輩の方こそ偉いですよって言った！")
                    .font(.subheadline)
                    .padding(.leading, 20)
                Spacer()
            }
            HStack(alignment: .center, spacing: 20) {
                Image(systemName: "heart")
                    .font(.title3)
                // MARK: Comment Icon
                HStack {
                    NavigationLink (
                        destination: CommentsView(post: $post),
                        label: {
                            Image(systemName: "bubble.middle.bottom")
                                .font(.title3)
                                .tint(.primary)
                        })
                    Text("0")
                    .font(.subheadline)                }
                Image(systemName: "paperplane")
                    .font(.title3)
                Spacer()
            }
        }
    }
}

#Preview {
    let post = PostModel(postID: "", userID: "", username: "hinakko", caption: "This is a test caption",dateCreated: Date(), likeCount: 0, likedByUser: false)
    return PostCell(post: post)
}
