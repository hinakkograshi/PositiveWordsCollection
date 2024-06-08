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
    @Binding var profileBio: String
    @ObservedObject var postArray: PostArrayObject
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 20, content: {
            // MARK: PROFILE PICTURE
            HStack(alignment: .center, spacing: 20, content: {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100, alignment: .leading)
                    .clipShape(RoundedRectangle(cornerRadius: 60))
                // MARK: USER NAME
                Text(profileDisplayName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            })

            // MARK: BIO
            Text(profileBio)
                .font(.title3)
                .fontWeight(.regular)
                .multilineTextAlignment(.center)
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 20, content: {
                // MARK: POSTS
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 5, content: {
                    HStack {
                        Image(systemName: "paperplane")
                        Text("20")
                            .font(.title2)
                            .fontWeight(.bold)
                    }

                    Capsule()
                        .fill(.gray)
                        .frame(width: 60, height: 3, alignment: .center)

                    Text("ポスト数")
                        .font(.callout)
                        .fontWeight(.medium)
                })
                // MARK: LIKES
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 5, content: {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                        Text("100")
                            .font(.title2)
                            .fontWeight(.bold)
                    }

                    Capsule()
                        .fill(.red)
                        .frame(width: 60, height: 3, alignment: .center)

                    Text("いいね数")
                        .font(.callout)
                        .fontWeight(.medium)
                })
            })
        })
        .padding()
    }
}

#Preview {
    @State var name: String = "hina"
    @State var bio = "iOSエンジニア目指して学習をしています。"
    @State var image: UIImage = UIImage(named: "posiIcon")!
    return ProfileHeaderView(profileDisplayName: $name, profileImage: $image, profileBio: $bio, postArray: PostArrayObject())
}
