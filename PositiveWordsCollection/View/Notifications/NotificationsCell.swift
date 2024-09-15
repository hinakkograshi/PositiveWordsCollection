//
//  NotificationsCell.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/09/14.
//

import SwiftUI

struct NotificationsCell: View {
    let notifications: Notification
    @State var profileImage = UIImage(named: "loading")!
    var body: some View {
        VStack {
            Button {
                //isPostImageViewShowing = true
            } label: {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40, alignment: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 60))
                    .overlay {
                        RoundedRectangle(cornerRadius: 60)
                            .stroke(Color.black, lineWidth: 1.0)
                    }
                    .padding(5)
                Spacer()
            }
            HStack {
                // post caption
                Text(notifications.userName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.black)
                if let notificationType = NotificationType(rawValue: notifications.type) {
                    switch notificationType {
                    case .like:
                        Text("さんがあなたの投稿にいいねしました！")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    case .reply:
                        Text("さんがあなたの投稿に返信しました！")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(5)
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.secondary)
        }
        .onAppear {
            getImages()
        }
    }
    func getImages() {
        // Get Profile image
        ImageManager.instance.downloadProfileImage(userID: notifications.userId) { returnedImage in
            if let image = returnedImage {
                self.profileImage = image
            }
        }
    }
}

#Preview {
   let notification = Notification(notificationId: "1", postId: "12", userId: "23", userName: "hinakko", dateCreated: Date(), type: 1)
    return NotificationsCell(notifications: notification)
}
