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
    @State var fetchOnAppear = false

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
                // 二回以降のMyProfile表示時更新
                isMyProfileUpdate()
                getProfileImage(profileUserID: profileUserID)
                getAdditionalProfileInfo()
            }
            .sheet(
                isPresented: $showEditProfileView,
                onDismiss: {
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
    func isMyProfileUpdate() {
        guard let userID = currentUserID else {return}
        Task {
            if isMyProfile {
                await posts.refreshOfUser(userID: userID)
            }
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
