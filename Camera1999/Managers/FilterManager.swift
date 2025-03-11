//
//  FilterManager.swift
//  Camera1999
//
//  Created by Sean Cho on 4/6/24.
//

import CoreImage
import Combine
import UIKit
import SwiftUI
import CoreImage.CIFilterBuiltins

class FilterManager: ObservableObject {
    static let shared = FilterManager()
    private let context = CIContext()
    
    private init() {
        self.getUserPresets()
    }
    
    @Published var selectedImage: UIImage? = nil
        
    @Published var selectedAspectRatioIndex: Int = 0
    
    let filmLabels: [String] = ["None", "Default", "ScratchA", "ScratchB", "CRTV", "CRTH",  "NoiseA", "NoiseB", "Grain", "BokehA", "BokehB"]
    @Published var currentFilmIndex: Int = 1
    
    let colorLabels: [String] = ["None", "Sakura", "Red", "Sepia", "Forest", "Ocean", "Mono", "Noir"]
    @Published var currentColorIndex: Int = 0
    
    let ratioLabels = ["4:3", "5:4", "1:1", "16:9"]
    let ratios: [CGFloat] = [3/4, 4/5, 1/1, 9/16]
    @Published var currentRatioIndex: Int = 0
    
    @Published var currentPresetIndex: Int = 0
    let presetLabels: [String] = ["0", "1", "2", "3", "4" ,"5", "6", "7", "8", "9"]
    
    var presets: [Preset] = [
        Preset(filmIndex: 1, colorIndex: 0, exposureKeyValue: 0.0, sharpnessKeyValue: 0.0, contrastKeyValue: 1.0, saturationKeyValue: 1.0, temperatureKeyValue: 6500.0),
        Preset(filmIndex: 1, colorIndex: 0, exposureKeyValue: 0.0, sharpnessKeyValue: 0.0, contrastKeyValue: 1.0, saturationKeyValue: 1.0, temperatureKeyValue: 6500.0),
        Preset(filmIndex: 2, colorIndex: 0, exposureKeyValue: 0.0, sharpnessKeyValue: 0.0, contrastKeyValue: 1.0, saturationKeyValue: 1.0, temperatureKeyValue: 6500.0),
        Preset(filmIndex: 3, colorIndex: 0, exposureKeyValue: 0.0, sharpnessKeyValue: 0.0, contrastKeyValue: 1.0, saturationKeyValue: 1.0, temperatureKeyValue: 6500.0),
        Preset(filmIndex: 4, colorIndex: 0, exposureKeyValue: 0.0, sharpnessKeyValue: 0.0, contrastKeyValue: 1.0, saturationKeyValue: 1.0, temperatureKeyValue: 6500.0),
        Preset(filmIndex: 5, colorIndex: 0, exposureKeyValue: 0.0, sharpnessKeyValue: 0.0, contrastKeyValue: 1.0, saturationKeyValue: 1.0, temperatureKeyValue: 6500.0),
        Preset(filmIndex: 6, colorIndex: 0, exposureKeyValue: 0.0, sharpnessKeyValue: 0.0, contrastKeyValue: 1.0, saturationKeyValue: 1.0, temperatureKeyValue: 6500.0),
        Preset(filmIndex: 7, colorIndex: 0, exposureKeyValue: 0.0, sharpnessKeyValue: 0.0, contrastKeyValue: 1.0, saturationKeyValue: 1.0, temperatureKeyValue: 6500.0),
        Preset(filmIndex: 8, colorIndex: 0, exposureKeyValue: 0.0, sharpnessKeyValue: 0.0, contrastKeyValue: 1.0, saturationKeyValue: 1.0, temperatureKeyValue: 6500.0),
        Preset(filmIndex: 9, colorIndex: 0, exposureKeyValue: 0.0, sharpnessKeyValue: 0.0, contrastKeyValue: 1.0, saturationKeyValue: 1.0, temperatureKeyValue: 6500.0)
    ]
    
    @Published var exposureKeyValue: Double = 0.0
    @Published var sharpnessKeyValue: Double = 0.0
    @Published var contrastKeyValue: Double = 1.0
    @Published var saturationKeyValue: Double = 1.0
    @Published var temperatureKeyValue: Double = 6500.0
    

    func processImage(image: CGImage) -> CGImage? {
        var ciImage = CIImage(cgImage: image)
        
        ciImage = applyGrainEffect(to: ciImage, with: filmLabels[currentFilmIndex]) ?? ciImage
            
        if currentColorIndex > 0 {
            if currentColorIndex == 1 {
                ciImage = applyColor(image: ciImage, color: .pink)
            }else if currentColorIndex == 2 {
                ciImage = applyColor(image: ciImage, color: .red)
            }else if currentColorIndex == 3 {
                ciImage = applySepia(image: ciImage)
            }else if currentColorIndex == 4 {
                ciImage = applyColor(image: ciImage, color: .green)
            }else if currentColorIndex == 5 {
                ciImage = applyColor(image: ciImage, color: .blue)
            }else if currentColorIndex == 6 {
                ciImage = applyMono(image: ciImage)
            }else if currentColorIndex == 7 {
                ciImage = applyNoir(image: ciImage)
            }
        }
        
        ciImage = applyExposure(image: ciImage)
        
        ciImage = applySharpness(image: ciImage)
        
        ciImage = applyColorControls(image: ciImage)
//
        ciImage = applyWhiteBalance(image: ciImage)
        
        // 모든 필터 적용 후, 마지막으로 이미지 크롭
        ciImage = cropedImage(ciImage: ciImage)
        
        return context.createCGImage(ciImage, from: ciImage.extent)
    }
    
    // UserDefaults에 현재 presets 저장하기
    func setUserPresets() {
        let encoder = JSONEncoder()
        if let encodedPresets = try? encoder.encode(presets) {
            UserDefaults.standard.set(encodedPresets, forKey: "presets")
        }
    }

    // UserDefaults에서 presets 가져오기
    func getUserPresets() {
        let decoder = JSONDecoder()
        if let savedPresetsData = UserDefaults.standard.data(forKey: "presets"),
           let loadedPresets = try? decoder.decode([Preset].self, from: savedPresetsData) {
            self.presets = loadedPresets
        }
    }
    
    func savePreset() {
        presets[currentPresetIndex] = Preset(filmIndex: currentFilmIndex, colorIndex: currentColorIndex, exposureKeyValue: exposureKeyValue, sharpnessKeyValue: sharpnessKeyValue, contrastKeyValue: contrastKeyValue, saturationKeyValue: saturationKeyValue, temperatureKeyValue: temperatureKeyValue)
        setUserPresets()
    }
    
    func applyPreset() {
        let preset = presets[currentPresetIndex]
//        #imageLiteral(resourceName: "Scratch1 2.png")
        // 현재 프리셋 값으로 필터 매니저의 설정 업데이트
        currentFilmIndex = preset.filmIndex
        currentColorIndex = preset.colorIndex
        exposureKeyValue = preset.exposureKeyValue
        sharpnessKeyValue = preset.sharpnessKeyValue
        contrastKeyValue = preset.contrastKeyValue
        saturationKeyValue = preset.saturationKeyValue
        temperatureKeyValue = preset.temperatureKeyValue
        
        // 각 설정 값들을 콘솔에 프린트
//        print("Applying Preset Index: \(currentPresetIndex)")
//        print("Film Index: \(preset.filmIndex)")
//        print("Color Index: \(preset.colorIndex)")
//        print("Exposure KeyValue: \(preset.exposureKeyValue)")
//        print("Sharpness KeyValue: \(preset.sharpnessKeyValue)")
//        print("Contrast KeyValue: \(preset.contrastKeyValue)")
//        print("Saturation KeyValue: \(preset.saturationKeyValue)")
//        print("Temperature KeyValue: \(preset.temperatureKeyValue)")
    }
    

    
    private func applyGrainEffect(to inputCIImage: CIImage, with grain: String) -> CIImage? {
        guard let grainImage = UIImage(named: grain) else {
            return nil
        }
        
        guard let grainCIImage = CIImage(image: grainImage) else {
//            print("Grain image not loaded.")
            return inputCIImage
        }
        
        // 그레인 이미지를 입력 이미지의 크기로 스케일링
        let scaleX = inputCIImage.extent.width / grainCIImage.extent.width
        let scaleY = inputCIImage.extent.height / grainCIImage.extent.height
        let scaledGrainCIImage = grainCIImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        // 그레인 이미지와 입력 이미지 결합
        let softLightBlendFilter = CIFilter(name: "CISoftLightBlendMode", parameters: [
            kCIInputImageKey: scaledGrainCIImage,
            kCIInputBackgroundImageKey: inputCIImage
        ])
        
        return softLightBlendFilter?.outputImage
    }
    
    private func applyColor(image: CIImage, color: Color) -> CIImage {
        return image.applyingFilter("CIColorMonochrome", parameters: [kCIInputColorKey: CIColor(color: UIColor(color)), kCIInputIntensityKey: 0.2])
    }
    
    private func applySepia(image: CIImage) -> CIImage {
        return image.applyingFilter("CISepiaTone", parameters: [kCIInputIntensityKey: 0.2])
    }
    
//    private func applyChrome(image: CIImage) -> CIImage {
//        return image.applyingFilter("CIPhotoEffectChrome", parameters: [:])
//    }
//    
//    private func applyInstant(image: CIImage) -> CIImage {
//        return image.applyingFilter("CIPhotoEffectInstant", parameters: [:])
//    }
//    
//    private func applyTime(image: CIImage) -> CIImage {
//        return image.applyingFilter("CIPhotoEffectTransfer", parameters: [:])
//    }
//    
//    private func applyOcean(image: CIImage) -> CIImage {
//        return image.applyingFilter("CIPhotoEffectProcess", parameters: [:])
//    }
    
    private func applyMono(image: CIImage) -> CIImage {
        return image.applyingFilter("CIPhotoEffectMono", parameters: [:])
    }
    
    private func applyNoir(image: CIImage) -> CIImage {
        return image.applyingFilter("CIPhotoEffectNoir", parameters: [:])
    }
    
    private func applyExposure(image: CIImage) -> CIImage {
        return image.applyingFilter("CIExposureAdjust", parameters: [
            kCIInputEVKey: exposureKeyValue])
    }
    
    private func applySharpness(image: CIImage) -> CIImage {
        return image.applyingFilter("CISharpenLuminance", parameters: [
            kCIInputSharpnessKey: sharpnessKeyValue])
    }
    
    private func applyColorControls(image: CIImage) -> CIImage {
        return image.applyingFilter("CIColorControls", parameters: [
            kCIInputContrastKey: contrastKeyValue,
            kCIInputSaturationKey: saturationKeyValue
        ])
    }
    
    private func applyWhiteBalance(image: CIImage) -> CIImage {
        return image.applyingFilter("CITemperatureAndTint", parameters: [
            "inputNeutral": CIVector(x: temperatureKeyValue, y: 0), // 온도 및 색조를 조절할 값
            "inputTargetNeutral": CIVector(x: 6500, y: 0)]) // 기본값, 필요에 따라 조절
    }
    
    private func cropedImage(ciImage: CIImage) -> CIImage {
        let originalAspectRatio = ciImage.extent.width / ciImage.extent.height
        let targetAspectRatio: CGFloat = ratios[currentRatioIndex]
        var cropRect: CGRect
        
        if originalAspectRatio > targetAspectRatio {
            // 이미지가 너무 넓은 경우
            let scaledHeight = ciImage.extent.height
            let scaledWidth = scaledHeight * targetAspectRatio
            cropRect = CGRect(x: (ciImage.extent.width - scaledWidth) / 2.0, y: 0, width: scaledWidth, height: scaledHeight)
        } else {
            // 이미지가 너무 높은 경우
            let scaledWidth = ciImage.extent.width
            let scaledHeight = scaledWidth / targetAspectRatio
            cropRect = CGRect(x: 0, y: (ciImage.extent.height - scaledHeight) / 2.0, width: scaledWidth, height: scaledHeight)
        }
        
        return ciImage.cropped(to: cropRect)
    }
}
