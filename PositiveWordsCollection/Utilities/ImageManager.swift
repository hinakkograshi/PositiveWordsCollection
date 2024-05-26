//
//  ImageManager.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/25.
//

import Foundation
import FirebaseStorage
import UIKit

class ImageManager {
    static let instance = ImageManager()
    private var storageREF = Storage.storage()

    func uploadProfileImage(userID: String, image: UIImage) async throws {
        // 画像を保存する場所のパス
        let path = getProfileImagePath(userID: userID)
        try await uploadImage(path: path, image: image)
    }

    private func getProfileImagePath(userID: String) -> StorageReference {
        let userPath = "users/\(userID)/profile"
        let storagePath = storageREF.reference(withPath: userPath)
        return storagePath
    }

    // 指定したパスに画像をアプロードする
    private func uploadImage(path: StorageReference, image: UIImage) async throws {

        var compression: CGFloat = 1.0
        let maxFileSize = 240 * 240
        let maxCompression = 0.05

        // get image data
        guard var originalData = image.jpegData(compressionQuality: compression) else {
            print("Error getting data from image")
            return
        }

        // Check maximum file size画像圧縮
        while (originalData.count > maxFileSize) && (compression > maxCompression) {
            compression -= 0.05
            if let compressedData = image.jpegData(compressionQuality: compression) {
                originalData = compressedData
            }
            print(compression)
        }

        // get image data
        guard let finalData = image.jpegData(compressionQuality: compression) else {
            print("Error getting data from image")
            return
        }
        // Get photo metaData
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        try await _ = path.putDataAsync(finalData, metadata: metadata)
    }
}
