//
//  ProfileView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/24.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("hiddenPostIDs") var hiddenPostIDs: [String] = []
    var isMyProfile: Bool
    @StateObject var posts: PostArrayObject
    @AppStorage(CurrentUserDefaults.bio) var currentBio: String?
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @State var profileImage = UIImage(named: "loading")!
    @State var profileBio: String
    @State var profileDisplayName: String
    var profileUserID: String
    @State var showEditProfileView: Bool = false
    @State var firstAppear = true
    @State var showBlockAlert = false

    var body: some View {
        ProfileHeaderView(profileUserID: profileUserID, profileDisplayName: $profileDisplayName, profileImage: $profileImage, profileBio: profileBio, isMyProfile: isMyProfile, posts: posts)
            .padding(.top, 10)
        Rectangle()
            .foregroundStyle(.orange)
            .frame(height: 2)
        ProfilePostView(posts: posts, isMyProfile: isMyProfile)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(colorScheme == .light ? Color.MyTheme.beigeColor : Color.orange, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)

            .toolbar {
                if isMyProfile {
                    Button(action: {
                        showEditProfileView = true
                    }, label: {
                        Text("編集")
                            .fontWeight(.bold)
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                    })
                } else {
                    Button(action: {
                        showBlockAlert = true
                    }, label: {
                        Image(systemName: "person.slash.fill")
                            .tint(.red)
                    })
                }
            }
            .onAppear {
                if firstAppear == true {
                    firstAppear = false
                    Task {
                        profileUpdate(userID: profileUserID)
                        getProfileImage(profileUserID: profileUserID)
                    }
                }
            }
            .alert("このユーザーをブロックしますか？", isPresented: $showBlockAlert, actions: {
                Button("戻る", role: .cancel) {

                }
                Button("ブロックする", role: .destructive) {
                    // 🟥ブロックする
                    Task {
                        blockUser(profileUserID: profileUserID)
                        guard let myUserID = currentUserID else { return }
                        await posts.refreshHomeFirst(hiddenPostIDs: hiddenPostIDs, myUserID: myUserID)
                    }
                }
            }, message: {
                Text("ブロックするとユーザーの投稿が見えなくなります。")
            })
            .sheet(
                isPresented: $showEditProfileView,
                onDismiss: {
                    Task {
                        profileUpdate(userID: profileUserID)
                        // 画像のリロードのタイミング
                        getProfileImage(profileUserID: profileUserID)
                        // 名前とBio
                        getAdditionalProfileInfo(userID: profileUserID)
                        guard let myUserId = currentUserID else {return}
                        await posts.refreshHomeFirst(hiddenPostIDs: hiddenPostIDs, myUserID: myUserId)
                        await posts.refreshUpdateMyUserPost(userID: profileUserID)
                    }
                },
                content: {
                    EditProfileView(userDisplayName: $profileDisplayName, userBio: profileBio, userImage: $profileImage)
                })
    }

    // MARK: FUNCTION
    private func blockUser(profileUserID: String) {
        guard let myUserID = currentUserID else { return }
        Task {
            do {
                try await AuthService.instance.addBlockedUser(myUserID: myUserID, blockedUserID: profileUserID)
                try await AuthService.instance.addBlockingUser(myUserID: myUserID, blockedUserID: profileUserID)
            } catch {
                print("🟥blockUserError: \(error)")
            }
        }
    }

    func profileUpdate(userID: String) {
        Task {
            if isMyProfile {
                posts.updateMyCounts(userID: userID)
                _ = await posts.refreshMyUserPost(userID: userID)
            } else {
                Task {
                    posts.resetUserPostArray()
                    posts.updateUserCounts(userID: userID)
                    _ = await posts.refreshUserPost(userID: userID)
                }
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
        ProfileView(isMyProfile: true, posts: PostArrayObject(), profileBio: "こんちゃ", profileDisplayName: "hina", profileUserID: "")
    }
}
