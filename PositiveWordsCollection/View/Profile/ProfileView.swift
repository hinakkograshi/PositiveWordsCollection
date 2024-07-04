//
//  ProfileView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/24.
//

import SwiftUI

struct ProfileView: View {
    var isMyProfile: Bool
    @ObservedObject var posts: PostArrayObject
    @AppStorage(CurrentUserDefaults.bio) var currentBio: String?
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @State var profileImage = UIImage(named: "loading")!
    @State var profileBio: String = ""
    @State var profileDisplayName: String
    var profileUserID: String
    @State var showEditProfileView: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @State var firstAppear = true

    var body: some View {
        ProfileHeaderView(profileUserID: profileUserID, profileDisplayName: $profileDisplayName, profileImage: $profileImage, profileBio: $profileBio, isMyProfile: isMyProfile, posts: posts)
            .padding(.top, 10)
        Rectangle()
            .foregroundStyle(.orange)
            .frame(height: 2)
        ProfilePostView(posts: posts, isMyProfile: isMyProfile)
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
                if firstAppear == true {
                    firstAppear = false
                    print("🟩初めて")
                    Task {
                        profileUpdate(userID: profileUserID)
                        getProfileImage(profileUserID: profileUserID)
                    }
                }
            }
            .sheet(
                isPresented: $showEditProfileView,
                onDismiss: {
                    Task {
                        profileUpdate(userID: profileUserID)
                        // 画像のリロードのタイミング
                        getProfileImage(profileUserID: profileUserID)
                        // 名前とBio
                        getAdditionalProfileInfo(userID: profileUserID)
                        await posts.refreshUpdateHome()
                        await posts.refreshUpdateMyUserPost(userID: profileUserID)
                    }
                },
                content: {
                    EditProfileView(userDisplayName: $profileDisplayName, userBio: $profileBio, userImage: $profileImage)
                    //　なくてもdarkモード対応できそう
                        .preferredColorScheme(colorScheme)
                })
    }
    // MARK: FUNCTION
    func profileUpdate(userID: String) {
        Task {
            if isMyProfile {
                _ = await posts.refreshMyUserPost(userID: userID)
                posts.updateCounts(userID: userID)
            } else {
                _ = await posts.refreshUserPost(userID: userID)
                posts.updateCounts(userID: userID)
            }
        }
    }
    private func getAdditionalProfileInfo(userID: String) {
        Task {
            do {
                let user = try await AuthService.instance.getUserInfo(userID: userID)
                self.profileDisplayName = user.displayName
                self.profileBio = user.bio
            } catch {
                print("getAdditionalProfileInfo Error")
            }
        }
    }
    private func getProfileImage(profileUserID: String) {
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
        ProfileView(isMyProfile: true, posts: PostArrayObject(), profileDisplayName: "hina", profileUserID: "")
    }
}
