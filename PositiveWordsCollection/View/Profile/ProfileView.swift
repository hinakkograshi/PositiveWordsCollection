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
    @State var profileBio: String = ""
    var profileUserID: String
    var posts: PostArrayObject
    @State var showSettings: Bool = false
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ProfileHeaderView(profileDisplayName: $profileDisplayName, profileImage: $viewModel.profileImage, profileBio: $profileBio, postArray: posts)
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
            print("⭐️ポストデータあれいの中身⭐️\(posts.dataArray)")
            viewModel.getProfileImage(profileUserID: profileUserID)
            getAdditionalProfileInfo()
        })
        .sheet(isPresented: $showSettings, content: {
            EditProfileView(profileImage: $viewModel.profileImage)
            //　なくてもdarkモード対応できそう
                .preferredColorScheme(colorScheme)
        })
    }
    // 編集更新された場合
    func getAdditionalProfileInfo() {
        Task {
            do {
                let (returnedName, returnedBio) = try await AuthService.instance.getUserInfo(userID: profileUserID)
                self.profileDisplayName = returnedName
                self.profileBio = returnedBio
            } catch {
                print("getAdditionalProfileInfo Error")
            }
        }
    }
}

#Preview {
    @State var selectedImage = UIImage(named: "hiyoko")!
    return NavigationStack {
        ProfileView(isMyProfile: true, profileDisplayName: "hina", profileUserID: "", posts: PostArrayObject(userID: ""))
    }
}
