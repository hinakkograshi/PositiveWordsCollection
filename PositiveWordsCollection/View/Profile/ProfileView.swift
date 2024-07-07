//
//  ProfileView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/24.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("hiddenPostIDs") var hiddenPostIDs: [String] = []
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
    @State var showBlockAlert = false

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
                if isMyProfile {
                    Button(action: {
                        showEditProfileView = true
                    }, label: {
                        Text("編集")
                    })
                    .tint(Color.MyTheme.purpleColor)
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
                    print("🟩初めて")
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
                    blockUser(profileUserID: profileUserID)

//                    reportPost()
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
                        await posts.refreshUpdateHome(hiddenPostIDs: hiddenPostIDs)
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
    // Block
    private func blockUser(profileUserID: String) {
        Task {
            guard let myUserID = currentUserID else { return }
            let blockedUser = BlockedUser(myblockingUser: myUserID, blockedUser: profileUserID)
            do {
                try DataService.instance.blockedUser(blockedUser: blockedUser)
            } catch {
                print("blockUserError: \(error)")
            }
        }
        print("⭐️\(profileUserID)")
        // 投稿をリフレッシュ
    }

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
