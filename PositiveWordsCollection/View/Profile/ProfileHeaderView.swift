//
//  ProfileHeaderView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/24.
//

import SwiftUI

struct ProfileHeaderView: View {
    var profileUserID: String
    @Binding var profileDisplayName: String
    @Binding var profileImage: UIImage
    @Binding var profileBio: String
    var isMyProfile: Bool
    @ObservedObject var posts: PostArrayObject
    
    var body: some View {
        VStack(alignment: .center, spacing: 10, content: {
            // MARK: PROFILE PICTURE
            HStack(alignment: .center, spacing: 20, content: {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80, alignment: .leading)
                    .clipShape(RoundedRectangle(cornerRadius: 60))
                    .overlay {
                        RoundedRectangle(cornerRadius: 60)
                            .stroke(Color.black, lineWidth: 1.0)
                    }
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
                        Text(posts.postCountString)
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
                        Text(posts.likeCountString)
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
//        .onAppear {
//            Task {
//                do {
//                    sumLike = try await sumLike(userID: profileUserID)
//                } catch {
//                    print("SumLikeError")
//
//                }
//            }
//        }
    }
//    func sumLike(userID: String) async throws -> String {
//            let sumOfLike = try await DataService.instance.sumLikePost(userID: userID)
//            return String(sumOfLike)
//    }
}

#Preview {
    @State var name: String = "hina"
    var id: String = "1"
    @State var bio = "iOSエンジニア目指して学習をしています。"
    @State var image: UIImage = UIImage(named: "posiIcon")!
    return ProfileHeaderView(profileUserID: id, profileDisplayName: $name, profileImage: $image, profileBio: $bio, isMyProfile: true, posts: PostArrayObject())
}
