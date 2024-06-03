//
//  ProfileHeaderView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/24.
//

import SwiftUI

struct ProfileHeaderView: View {
    @Binding var profileDisplayName: String
    @Binding var profileImage: UIImage
//    @ObservedObject var postArray: PostArrayObject
    var profileBio: String
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 10, content: {
            // MARK: PROFILE PICTURE
            HStack(alignment: .center, spacing: 20, content: {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120, alignment: .leading)
                    .clipShape(RoundedRectangle(cornerRadius: 60))
                // MARK: USER NAME
                Text(profileDisplayName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            })

            // MARK: BIO
            Text(profileBio)
                .font(.body)
                .fontWeight(.regular)
                .multilineTextAlignment(.center)
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 20, content: {
                // MARK: POSTS
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 5, content: {
                    Text("5")
                        .font(.title2)
                        .fontWeight(.bold)

                    Capsule()
                        .fill(.gray)
                        .frame(width: 20, height: 2, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)

                    Text("Post")
                        .font(.callout)
                        .fontWeight(.medium)
                })
                // MARK: LIKES
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 5, content: {
                    Text("20")
                        .font(.title2)
                        .fontWeight(.bold)

                    Capsule()
                        .fill(.gray)
                        .frame(width: 20, height: 2, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)

                    Text("Likes")
                        .font(.callout)
                        .fontWeight(.medium)
                })
            })
        })
        .padding()
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    @State var name: String = "hina"
    @State var image: UIImage = UIImage(named: "hiyo")!
    return ProfileHeaderView(profileDisplayName: $name, profileImage: $image, profileBio: name)
}
