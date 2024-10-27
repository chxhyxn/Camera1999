//
//  UIImageExtension.swift
//  Camera1999
//
//  Created by Sean Cho on 4/6/24.
//

import Foundation
import UIKit

extension UIImage {
    func rotated(byDegrees degrees: CGFloat) -> UIImage? {
        let radians = degrees * CGFloat.pi / 180
        var newSize = CGRect(origin: .zero, size: self.size).applying(CGAffineTransform(rotationAngle: radians)).size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        context.rotate(by: radians)
        self.draw(in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))

        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return rotatedImage
    }
}

extension UIImage {
    func flippedHorizontally() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // 이미지를 그리기 전에 좌우 반전
        context.translateBy(x: self.size.width, y: 0)
        context.scaleBy(x: -1.0, y: 1.0)

        self.draw(in: CGRect(origin: .zero, size: self.size))

        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return flippedImage
    }
}

extension UIImage {
    func fixOrientation() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }

        if self.imageOrientation == .up { return self }

        var transform = CGAffineTransform.identity

        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
        case .up, .upMirrored:
            break
        @unknown default:
            return self
        }

        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: self.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: self.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            return self
        }

        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
                            bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0,
                            space: cgImage.colorSpace!,
                            bitmapInfo: cgImage.bitmapInfo.rawValue)
        ctx?.concatenate(transform)

        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
        default:
            ctx?.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }

        guard let newCGImage = ctx?.makeImage() else { return nil }
        return UIImage(cgImage: newCGImage)
    }
}
