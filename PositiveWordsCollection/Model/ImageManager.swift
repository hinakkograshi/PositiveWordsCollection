//
//  ImageManager.swift
//  PositiveWordsCollection
//
//  Created by Hina on 2024/05/25.
//

import FirebaseStorage
import UIKit

// Objectにたくさんの画像キャッシュ
class ImageManager {
    static let instance = ImageManager()
    private var storageREF = Storage.storage()
    let imageCache = NSCache<StorageReference, UIImage>()
    let fileManager = FileManager.default
    
    func createdProfileImage(userID: String, image: UIImage) async throws {
        let path = getProfileImagePath(userID: userID)
        try await uploadImage(path: path, image: image)
    }

    func uploadProfileImage(userID: String, image: UIImage) async throws {
        let path = getProfileImagePath(userID: userID)
        let key = path.fullPath.data(using: .utf8)?.base64EncodedString() ?? UUID().uuidString
        try chashRemove(key: key)
        try await uploadImage(path: path, image: image)
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
    
    private func chashRemove(key: String) throws {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let fileURL = cacheDirectory.appendingPathComponent(key)
            try FileManager.default.removeItem(at: fileURL)
    }
    
    private func downloadDiskCacheImage(path: StorageReference, handler: @escaping (_ image: UIImage?) -> Void) {
        let key = path.fullPath.data(using: .utf8)?.base64EncodedString() ?? UUID().uuidString
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileURL = cacheDirectory.appendingPathComponent(key)

        if let imageData = try? Data(contentsOf: fileURL) {
            let readImage = UIImage(data: imageData)
            // キャッシュされている画像を使用
            handler(readImage)
        } else {
            path.getData(maxSize: 27 * 1024 * 1024) { returnedImageData, _ in
                guard let data = returnedImageData, let image = UIImage(data: data) else { return }
                // 初めて画像を使用
                if let data = image.jpegData(compressionQuality: 1.0) {
                    do {
                        try data.write(to: fileURL)
                    } catch {
                        print("画像のディスク保存に失敗: \(error)")
                        handler(nil)
                        return
                    }
                }
                handler(image)
            }
        }
    }
    
    private func downloadMemoryCacheImage(path: StorageReference, handler: @escaping (_ image: UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: path) {
            // キャッシュされている画像を使用
            handler(cachedImage)
        } else {
            path.getData(maxSize: 27 * 1024 * 1024) { returnedImageData, _ in
                if let data = returnedImageData, let image = UIImage(data: data) {
                    // 初めて画像を使用
                    self.imageCache.setObject(image, forKey: path)
                    handler(image)
                } else {
                    print("Error getting data from path for image")
                    handler(nil)
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
