//
//  ImageManager.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/25.
//

import Foundation
import FirebaseStorage
import UIKit

// Objectにたくさんの画像キャッシュ
let imageCache = NSCache<AnyObject, UIImage>()

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

    func downloadProfileImage(userID: String, handler: @escaping (_ image: UIImage?) -> Void) {
        // Where the image is saved
        let path = getProfileImagePath(userID: userID)
        // Download image path
        DispatchQueue.global(qos: .userInteractive).async {
            self.downloadImage(path: path) { returnedImage in
                DispatchQueue.main.async {
                    handler(returnedImage)
                }
            }
        }
    }

    private func downloadImage(path: StorageReference, handler: @escaping (_ image: UIImage?) -> Void) {
        // キャッシュされていたらそれを使用
        if let cachedImage = imageCache.object(forKey: path) {
            print("Image found in cache")
            handler(cachedImage)
            return
        } else {
            // 初めてキャッシュ
            path.getData(maxSize: 27 * 1024 * 1024) { returnedImageData, _ in
                if let data = returnedImageData, let image = UIImage(data: data) {
                    // Success getting Image
                    imageCache.setObject(image, forKey: path)
                    handler(image)
                    return
                } else {
                    print("Error getting data from path for image")
                    handler(nil)
                    return
                }
            }
        }
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
