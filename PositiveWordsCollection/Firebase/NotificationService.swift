//
//  NotificationService.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/09/14.
//

import Foundation
import Firebase

class NotificationService {
    static let instance = NotificationService()
    private let notificationsCollection = Firestore.firestore().collection("notifications")

    private func subCollection(userId: String) -> CollectionReference {
        notificationsCollection.document(userId).collection("user_notifications")
    }

    func downloadNotification( myUserID: String) async throws -> ([Notification]) {
        let notifications = try await subCollection(userId: myUserID)
            .order(by: DatabaseHelperField.dateCreated, descending: true).limit(to: 10).getDocuments()
            .documents.compactMap { try? $0.data(as: Notification.self)
            }
        return notifications
    }

    func uploadNotification(postedUserId: String, notification: Notification) async {
        do {
            try await notificationsCollection.document(postedUserId).setData([
                "notified_user": FieldValue.arrayUnion([notification.userId])
            ])
            try subCollection(userId: postedUserId).document(notification.notificationId).setData(from: notification)
        } catch {
            print("🟥Error uploading notification to firebase\(error)")
        }
    }

    func createNotificationId() -> String {
        let document = notificationsCollection.document()
        let notificationID = document.documentID
        return notificationID
    }
}
