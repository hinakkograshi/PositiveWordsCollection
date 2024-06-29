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
    @State var profileBio: String = ""
    @State var profileDisplayName: String
    var profileUserID: String
    @StateObject var posts = PostArrayObject()
    @State var showEditProfileView: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @State var fetchOnAppear = false

    var body: some View {
        ProfileHeaderView(profileDisplayName: $profileDisplayName, profileImage: $profileImage, profileBio: $profileBio, postArray: posts)
            .padding(.top, 10)
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
                profileUpdate()
                getProfileImage(profileUserID: profileUserID)
                getAdditionalProfileInfo()
            }
            .sheet(
                isPresented: $showEditProfileView,
                onDismiss: {
                    posts.refreshUserPost(userID: profileUserID)
                    // 画像のリロードのタイミング
                    getProfileImage(profileUserID: profileUserID)
                },
                content: {
                    EditProfileView(userDisplayName: $profileDisplayName, userBio: $profileBio, userImage: $profileImage)
                    //　なくてもdarkモード対応できそう
                        .preferredColorScheme(colorScheme)
                })
    }
    // MARK: FUNCTION
    func profileUpdate() {
        Task {
            print("🌺UserProfile")
            posts.refreshUserPost(userID: profileUserID)

        }
    }
    func getAdditionalProfileInfo() {
        Task {
            do {
                let user = try await AuthService.instance.getUserInfo(userID: profileUserID)
                self.profileDisplayName = user.displayName
                self.profileBio = user.bio
            } catch {
                print("getAdditionalProfileInfo Error")
            }
        }
    }
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
