//
//  MessageView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/22.
//

import SwiftUI

struct MessageView: View {
    @State var comment: CommentModel
    @State var profileImage = UIImage(named: "loading")!
    var body: some View {
        HStack {
            NavigationLink(destination: LazyView(content: {
                ProfileView(isMyProfile: false, profileDisplayName: comment.username, profileUserID: comment.userID)
            }), label: {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40, alignment: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            })
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
        .onAppear(perform: {
            getProfileImage()
        })
    }
    // MARK: FUNCTION
    func getProfileImage() {
        ImageManager.instance.downloadProfileImage(userID: comment.userID) { returnedImage in
            if let image = returnedImage {
                // プロフィール画像更新
                self.profileImage = image
            }
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let comment = CommentModel(commentID: "", userID: "", username: "hinakko", content: "This photo is really cool. haha", dateCreated: Date())
   return MessageView(comment: comment)
}
