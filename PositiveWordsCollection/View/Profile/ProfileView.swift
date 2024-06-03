//
//  ProfileView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/24.
//

import SwiftUI

struct ProfileView: View {
    var isMyProfile: Bool
    @StateObject private var viewModel = ProfileViewModel()
    @AppStorage(CurrentUserDefaults.bio) var currentBio: String?
    @State var profileDisplayName: String
    var profileUserID: String
    var posts: PostArrayObject
    @State var showSettings: Bool = false
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        if let bio = currentBio {
            ProfileHeaderView(profileDisplayName: $profileDisplayName, profileImage: $viewModel.profileImage, profileBio: bio)
        }
        Rectangle()
            .foregroundStyle(.orange)
            .frame(height: 2)
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                ForEach(posts.dataArray, id: \.self) { post in
                    PostView(post: post)
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)

        .toolbar {
            Button(action: {
                showSettings.toggle()

            }, label: {
                Text("編集")
            })
            .tint(colorScheme == .light ? Color.MyTheme.purpleColor: Color.MyTheme.yellowColor)
            .opacity(isMyProfile ? 1.0 : 0.0)
        }
        .onAppear(perform: {
            viewModel.getProfileImage(profileUserID: profileUserID)
        })
        .sheet(isPresented: $showSettings, content: {
            EditProfileView(profileImage: $viewModel.profileImage)
            //　なくてもdarkモード対応できそう
                .preferredColorScheme(colorScheme)
        })
    }
}

#Preview {
    @State var selectedImage = UIImage(named: "hiyoko")!
    return NavigationStack {
        ProfileView(isMyProfile: true, profileDisplayName: "hina", profileUserID: "", posts: PostArrayObject(userID: ""))
    }
}
