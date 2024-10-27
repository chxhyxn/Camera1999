//
//  ContentViewModel.swift
//  Camera1999
//
//  Created by Sean Cho on 4/5/24.
//

import CoreImage
import Photos
import UIKit
import SwiftUI
import AVFoundation

class ContentViewModel: ObservableObject {
    private let cameraManager = CameraManager.shared
    private let frameManager = FrameManager.shared
    private let filterManager = FilterManager.shared
    private let libraryManager = LibraryManager.shared
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    var audioPlayer: AVAudioPlayer?
    
    @Published var error: Error?
    @Published var frame: CGImage?
    @Published var saveMessage: String?
    @Published var isBusy: Bool = false
    @Published var flipEffect: Bool = false
    @Published var showFrameView = true
    @Published var isBlurred = false
    @Published var isImagePickerPresented = false
    @Published var showGrid: Bool = false
    @Published var lastScaleValue: CGFloat = 1.0
    @Published var showControlView: Bool = false
    @Published var controlValue: String = ""
    
    private let context = CIContext()
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        cameraManager.$error
            .receive(on: RunLoop.main)
            .map { $0 }
            .assign(to: &$error)
        
        frameManager.$current
            .receive(on: DispatchQueue.main)
            .compactMap { buffer in
                guard let image = CGImage.create(from: buffer) else {
                    return nil
                }
                
                return self.filterManager.processImage(image: image)
            }
            .assign(to: &$frame)
    }
    
    private func processPicture() {
        guard let frame = frame else { return }
        
        if self.cameraManager.currentCameraPosition == .front {
            // CGImage를 CIImage로 변환
            let ciImage = CIImage(cgImage: frame)
            
            // 이미지 좌우 반전
            let flippedImage = ciImage.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
            
            // 처리된 CIImage를 다시 CGImage로 변환
            if let processedCGImage = context.createCGImage(flippedImage, from: flippedImage.extent) {
                saveImage(image: processedCGImage)
            }
        }else {
            saveImage(image: frame)
        }
    }
    
    func saveImage(image: CGImage) {
        libraryManager.saveImageToLibrary(image) { success, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if success {
                    self.saveMessage = "Photo saved"
                } else if let error = error {
                    self.saveMessage = "Error saving photo: \(error.localizedDescription)"
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.saveMessage = nil
            }
        }
    }
    
    func savePreset(label: String) {
        filterManager.savePreset()
        DispatchQueue.main.async {
            self.saveMessage = "Preset " + label + " saved"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.saveMessage = nil
        }
    }
    
    func switchCamera() {
        self.showControlView = false
        cameraManager.switchCamera()
    }
    
    func feedback() {
        feedbackGenerator.impactOccurred()
    }
    
    func takePicture() {
        if !self.isBusy {
            self.isBusy = true
            // shutter.mp3 재생
            playShutterSound()
            feedbackGenerator.impactOccurred()
            
            self.showControlView = false
            
            withAnimation(.easeInOut(duration: 0.3)) {
                showFrameView = false
            }
            
            // 사진 찍는 동작 수행
            self.processPicture()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.showFrameView = true
                    self.isBusy = false
                }
            }
        }
    }
    
    private func playShutterSound() {
        guard let path = Bundle.main.path(forResource: "shutter", ofType: "mp3") else { return }
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
//            print("Unable to play shutter sound")
        }
    }
}
