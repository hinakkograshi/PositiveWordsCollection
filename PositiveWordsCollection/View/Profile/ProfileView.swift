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
            EditProfileView()
            //　なくてもdarkモード対応できそう
                .preferredColorScheme(colorScheme)
        })
    }
}

#Preview {
    NavigationStack {
        ProfileView(isMyProfile: true, profileDisplayName: "hina", profileUserID: "")
    }
}
