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
        VStack(alignment: .center, spacing: 10, content: {
            // MARK: PROFILE PICTURE
            HStack(alignment: .center, spacing: 20, content: {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80, alignment: .leading)
                    .clipShape(RoundedRectangle(cornerRadius: 60))
                // MARK: USER NAME
                Text(profileDisplayName)
                    .font(.title)
                    .fontWeight(.bold)
            })

            // MARK: BIO
            if profileBio != "" {
                Text(profileBio)
                    .font(.title3)
                    .fontWeight(.regular)
                    .multilineTextAlignment(.center)
            }
            HStack(alignment: .center, spacing: 50, content: {
                // MARK: POSTS
                VStack(alignment: .center, spacing: 5, content: {
                    HStack {
                        Image(systemName: "paperplane")
                        Text(postArray.postCountString)
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
                VStack(alignment: .center, spacing: 5, content: {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                        Text(postArray.likeCountString)
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
    }
}

#Preview {
    @State var name: String = "hina"
    @State var bio = "iOSエンジニア目指して学習をしています。"
    @State var image: UIImage = UIImage(named: "posiIcon")!
    return ProfileHeaderView(profileDisplayName: $name, profileImage: $image, profileBio: $bio, postArray: PostArrayObject())
}
