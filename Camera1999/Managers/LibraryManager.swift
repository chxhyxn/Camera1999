//
//  LibraryManager.swift
//  Camera1999
//
//  Created by Sean Cho on 4/6/24.
//

import Photos
import UIKit

class LibraryManager {
    static let shared = LibraryManager()

    @Published var error: CameraError?
    
    private init() {}
    
    private func set(error: CameraError?) {
        DispatchQueue.main.async {
            self.error = error
        }
    }

    func saveImageToLibrary(_ cgImage: CGImage, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            
            guard status == .authorized else {
                self.set(error:.deniedLibraryAccess)
                completion(false, NSError(domain: "LibraryManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Photo Library access denied"]))
                return
            }

            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: self.jpegData(from: cgImage), options: nil)
            }, completionHandler: { success, error in
                DispatchQueue.main.async {
                    completion(success, error)
                }
            })
        }
    }

    private func jpegData(from cgImage: CGImage) -> Data {
        let uiImage = UIImage(cgImage: cgImage)
        return uiImage.jpegData(compressionQuality: 1.0) ?? Data()
    }
}
