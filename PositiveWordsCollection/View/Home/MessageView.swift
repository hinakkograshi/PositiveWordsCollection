//
//  MessageView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/22.
//

import SwiftUI

struct MessageView: View {
    @State var comment: CommentModel
    var body: some View {
        HStack {
            Image("hiyoko")
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            VStack(alignment: .leading, spacing: 4, content: {
                Text(comment.username)
                    .font(.caption)
                    .foregroundStyle(.gray)
                Text(comment.content)
                    .padding(10)
                    .foregroundStyle(.primary)
                    .background(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            })
            Spacer(minLength: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    var comment = CommentModel(commentID: "", userID: "", username: "hinakko", content: "This photo is really cool. haha", dateCreated: Date())
   return MessageView(comment: comment)
}

