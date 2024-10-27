//
//  FrameView.swift
//  Camera1999
//
//  Created by Sean Cho on 4/5/24.
//

import SwiftUI

struct FrameView: View {
    var image: CGImage?
    var showGrid: Bool
    
    private let label = Text("1999")
    
    var body: some View {
        if let image = image {
            GeometryReader { geometry in
                let finalSize = calculateScaledToFitSize(imageSize: CGSize(width: image.width, height: image.height), containerSize: geometry.size)
                
                Image(image, scale: 1.0, orientation: .upMirrored, label: label)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height,
                        alignment: .center)
                    .clipped()
                    .overlay(
                        ZStack {
                            CornerGridPattern()
                                .stroke(Color.white.opacity(0.8), lineWidth: 3)
                                .frame(width: finalSize.width, height: finalSize.height)
                            if showGrid {
                                GridPattern()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    .frame(width: finalSize.width, height: finalSize.height)
                            }
                        }
                    )
            }
        } else {
            Color.black
        }
    }
    // 이미지와 컨테이너 크기를 기반으로 최종 크기 계산
    func calculateScaledToFitSize(imageSize: CGSize, containerSize: CGSize) -> CGSize {
        let imageAspectRatio = imageSize.width / imageSize.height
        let containerAspectRatio = containerSize.width / containerSize.height
        
        var finalSize = CGSize.zero
        
        if imageAspectRatio > containerAspectRatio {
            finalSize.width = containerSize.width
            finalSize.height = containerSize.width / imageAspectRatio
        } else {
            finalSize.width = containerSize.height * imageAspectRatio
            finalSize.height = containerSize.height
        }
        
        return finalSize
    }
}
