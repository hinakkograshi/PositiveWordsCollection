//
//  ProfileView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/24.
//

import SwiftUI

struct ProfileView: View {
    var isMyProfile: Bool
    @State var profileDisplayName: String
    var profileUserID: String
    var posts = PostArrayObject()
    @State var showSettings: Bool = false
    @Environment(\.colorScheme) var colorScheme
    var userProfilePicture = UIImage(named: "hiyoko")!
    @State var image = UIImage(named: "hiyoko")!
    var body: some View {

        ProfileHeaderView(profileDisplayName: $profileDisplayName)
            Rectangle()
                .foregroundStyle(.orange)
                .frame(height: 2)
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                ForEach(posts.dataArray, id: \.self) { post in
                    PostCell(post: post)
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
        .sheet(isPresented: $showSettings, content: {
            EditProfileView(profileImage: $image, selectedImage: userProfilePicture)
            //　なくてもdarkモード対応できそう
                .preferredColorScheme(colorScheme)
        })
    }
}

#Preview {
    @State var selectedImage = UIImage(named: "hiyoko")!
    return NavigationStack {
        ProfileView(isMyProfile: true, profileDisplayName: "hina", profileUserID: "")
    }
}
