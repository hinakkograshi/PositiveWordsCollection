//
//  ImageManager.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/25.
//

import Foundation
import FirebaseStorage
import UIKit
import Nuke

// Objectにたくさんの画像キャッシュ


class ImageManager {
    static let instance = ImageManager()
    private var storageREF = Storage.storage()
    let imageCache = NSCache<StorageReference, UIImage>()

    func uploadProfileImage(userID: String, image: UIImage) async throws {
        // 画像を保存する場所のパス
        let path = getProfileImagePath(userID: userID)
        try await uploadImage(path: path, image: image)
        print("ProfileImageを保存")
    }

    private func getProfileImagePath(userID: String) -> StorageReference {
        let userPath = "users/\(userID)/profile"
        let storagePath = storageREF.reference(withPath: userPath)
        return storagePath
    }

    func uploadPostImage(postID: String, image: UIImage) async throws {
        let path = getPostImagePath(postID: postID)
        try await uploadImage(path: path, image: image)
    }

    private func getPostImagePath(postID: String) -> StorageReference {
        // 写真が複数投稿できる場合
        let postPath = "posts/\(postID)/1"
        let storagePath = storageREF.reference(withPath: postPath)
        return storagePath
    }

    func downloadProfileImage(userID: String, handler: @escaping (_ image: UIImage?) -> Void) {
        // Where the image is saved
        let path = getProfileImagePath(userID: userID)
        // Download image from path
        DispatchQueue.global(qos: .userInteractive).async {
            self.downloadDiskCacheImage(path: path) { returnedImage in
                DispatchQueue.main.async {
                    handler(returnedImage)
                }
            }
        }
    }

    func downloadPostImage(postID: String, handler: @escaping (_ image: UIImage?) -> Void) {
        // Where the image is saved
        let path = getPostImagePath(postID: postID)
        // Download image path
        DispatchQueue.global(qos: .userInteractive).async {
            self.downloadMemoryCacheImage(path: path) { returnedImage in
                DispatchQueue.main.async {
                    handler(returnedImage)
                }
            }
        }
    }

    func chashRemove() {
        imageCache.removeAllObjects()
        //        removeObject(forKey: path)
    }


    func getDownloadURL(from storageReference: StorageReference, completion: @escaping (URL?) -> Void) {
        storageReference.downloadURL { url, error in
            if let error = error {
                print("Error getting download URL: \(error)")
                completion(nil)
                return
            }
            completion(url)
        }
    }

    func downloadDiskCacheImage(path: StorageReference, handler: @escaping (_ image: UIImage?) -> Void) {
        getDownloadURL(from: path) { url in
            guard let url = url else {
                handler(nil)
                return
            }

            // 画像の取得リクエスト
            let request = ImageRequest(url: url)

            // ImagePipelineの設定（必要に応じて）
            //            let pipeline = ImagePipeline.shared
            let config: ImagePipeline.Configuration = .withDataCache
            let pipeline = ImagePipeline(configuration: config)

            // 画像の取得
            if let cachedImage = pipeline.cache[request] {
                print("🟩キャッシュされた画像を使用")
                handler(cachedImage.image)
            } else {
                pipeline.loadImage(with: request) { result in
                    switch result {
                    case .success(let response):
                        print("🟩画像を取得")
                        handler(response.image)
                    case .failure(let error):
                        print("Error loading image: \(error)")
                        handler(nil)
                    }
                }
            }
        }
    }

    private func downloadMemoryCacheImage(path: StorageReference, handler: @escaping (_ image: UIImage?) -> Void) {
        // キャッシュしていたらそれを使用
        if let cachedImage = imageCache.object(forKey: path) {
            print("🟩キャッシュした画像を使用")
            handler(cachedImage)
            return
        } else {
            // 初めてキャッシュ
            path.getData(maxSize: 27 * 1024 * 1024) { returnedImageData, _ in
                if let data = returnedImageData, let image = UIImage(data: data) {
                    // Success getting Image
                    self.imageCache.setObject(image, forKey: path)
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
            print("Error getting originalData from image")
            throw AsyncError(message: "Error getting originalData from image")
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
            throw AsyncError(message: "Error getting data from image")
        }
        // Get photo metaData
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        try await _ = path.putDataAsync(finalData, metadata: metadata)
    }
}
