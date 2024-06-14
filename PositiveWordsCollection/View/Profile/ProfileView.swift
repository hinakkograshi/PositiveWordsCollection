//
//  ProfileView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/24.
//

import SwiftUI

struct ProfileView: View {
    var isMyProfile: Bool
    @State var profileImage = UIImage(named: "loading")!
    @AppStorage(CurrentUserDefaults.bio) var currentBio: String?
    @State var profileDisplayName: String
    @State var profileBio: String = ""
    var profileUserID: String
    @StateObject var posts: PostArrayObject
    @State var showEditProfileView: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?

    init(
        isMyProfile: Bool,
        profileDisplayName: String,
        profileUserID: String) {
            self.isMyProfile = isMyProfile
            self.profileDisplayName = profileDisplayName
            self.profileUserID = profileUserID
            self._posts = StateObject(wrappedValue: PostArrayObject(userID: profileUserID))
        }

    var body: some View {
        ProfileHeaderView(profileDisplayName: $profileDisplayName, profileImage: $profileImage, profileBio: $profileBio, postArray: posts)
        Rectangle()
            .foregroundStyle(.orange)
            .frame(height: 2)
        ProfilePostView(posts: posts)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.colorBeige, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)

            .toolbar {
                Button(action: {
                    showEditProfileView = true
                }, label: {
                    Text("編集")
                })
                .tint(colorScheme == .light ? Color.MyTheme.purpleColor: Color.MyTheme.yellowColor)
                .opacity(isMyProfile ? 1.0 : 0.0)
            }
            .onAppear {           
                getProfileImage(profileUserID: profileUserID)
            }
            .sheet(
                isPresented: $showEditProfileView,
                onDismiss: {
                    // TODO: -画像の取得方法要修正。画像ごとのUUID作成
                    Task {
                    await posts.refreshOfUser(userID: profileUserID)
                    // 画像のリロードのタイミング
                        getProfileImage(profileUserID: profileUserID)
                    }
                },
                content: {
                    EditProfileView(userDisplayName: $profileDisplayName, userBio: $profileBio, userImage: $profileImage)
                    //　なくてもdarkモード対応できそう
                        .preferredColorScheme(colorScheme)
                })
    }
    // MARK: FUNCTION
    func getProfileImage(profileUserID: String) {
        ImageManager.instance.downloadProfileImage(userID: profileUserID) { returnedImage in
            if let image = returnedImage {
                // プロフィール画像更新
                self.profileImage = image
            }
        }
    }
}

#Preview {
    @State var selectedImage = UIImage(named: "hiyoko")!
    return NavigationStack {
        ProfileView(isMyProfile: true, profileDisplayName: "hina", profileUserID: "")
    }
}
