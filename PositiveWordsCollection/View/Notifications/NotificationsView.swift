//
//  NotificationsView.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/09/14.
//

import SwiftUI

struct NotificationsView: View {
    @State var notifications = [Notification]()
    @ObservedObject var posts: PostArrayObject
    @State var isLastPost = false
    @AppStorage(CurrentUserDefaults.userID) var currentUserID: String?
    @State var loadingState: LoadingState = .idle
    var body: some View {
        VStack {
            if !notifications.isEmpty {
                switch loadingState {
                case .idle, .loading:
                    EmptyView()
                case .success:
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack {
                            
                            ForEach(notifications) { notification in
                                NotificationsCell(notification: notification, posts: posts)
                            }
                        }
                    }
                case .failure:
                    ContentUnavailableView {
                        Label("結果なし", systemImage: "magnifyingglass")
                    } description: {
                        Text("電波の良いところで通信してください。")
                    }
                }
                
            } else {
                ContentUnavailableView {
                    Label("通知なし", systemImage: "tray.fill")
                } description: {
                    Text("他のユーザーからの通知がありません。")
                }
            }
        }
        .overlay {
            if loadingState.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding()
                    .tint(Color.white)
                    .background(Color.gray)
                    .cornerRadius(8)
                    .scaleEffect(1.2)
            }
        }
        .task {
            guard let myUserID = currentUserID else { return }
            await notify(myUserID: myUserID)
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.colorBeige, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    private func notify(myUserID: String) async {
        loadingState = .loading
        do {
            notifications = try await NotificationService.instance.downloadNotification(myUserID: myUserID)
            loadingState = .success
        } catch {
            print("download Notification Error")
        }
    }
}

#Preview {
    let notifications = [Notification(notificationId: "1", postId: "12", userId: "23", userName: "hinakko", dateCreated: Date(), type: 1),
                         Notification(notificationId: "1", postId: "12", userId: "23", userName: "oba", dateCreated: Date(), type: 2)]

    return NotificationsView(notifications: notifications, posts: PostArrayObject())
}
