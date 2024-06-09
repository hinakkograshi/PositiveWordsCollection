//
//  ProfileView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/24.
//

import SwiftUI

struct ProfileView: View {
    var isMyProfile: Bool
    //    @StateObject private var viewModel = ProfileViewModel()
    @State var profileImage = UIImage(named: "loading")!
    @AppStorage(CurrentUserDefaults.bio) var currentBio: String?
    @State var profileDisplayName: String
    @State var profileBio: String = ""
    var profileUserID: String
    @StateObject var posts: PostArrayObject
    @State var showSettings: Bool = false
    @Environment(\.colorScheme) var colorScheme

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
                getProfileImage(profileUserID: profileUserID)

            })
            .sheet(
                isPresented: $showSettings,
                onDismiss: {
                    posts.refreshOfUser(userID: profileUserID)
                    // 画像のリロードのタイミング
                    DispatchQueue.main.asyncAfter(deadline: .now()+20) {
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
                print("🟩アンラップ成功")
                // プロフィール画像更新
                self.profileImage = image
            } else {
                print("🟥アンラップ失敗")
            }
        }
    }
}

//#Preview {
//    @State var selectedImage = UIImage(named: "hiyoko")!
//    return NavigationStack {
//        ProfileView(isMyProfile: true, profileDisplayName: "hina", profileUserID: "", posts: PostArrayObject(userID: ""))
//    }
//}
