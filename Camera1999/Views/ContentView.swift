//
//  ContentView.swift
//  Camera1999
//
//  Created by Sean Cho on 4/5/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var model = ContentViewModel()
    
    @ObservedObject private var filterManager = FilterManager.shared
    private let cameraManager = CameraManager.shared
    
    
    var body: some View {
        VStack {
            VStack {
                // 상단 UI
                HStack {
                    if let saveMessage = model.saveMessage {
                        Text(saveMessage)
                    }
                    else if let error = model.error {
                        Text(error.localizedDescription)
                            .foregroundStyle(.red)
                    }else {
                        // Film 조정 버튼
                        Button(action: {
                            menuButtonAction(value: "Film")
                        }) {
                            if filterManager.currentFilmIndex > 0 {
                                Text(filterManager.filmLabels[filterManager.currentFilmIndex])
                            }else {
                                Text("Film")
                                    .tint(.white)
                            }
                        }
                        Spacer()
                        
                        // 색상 조정 버튼
                        Button(action: {
                            menuButtonAction(value: "Color")
                        }) {
                            if filterManager.currentColorIndex > 0 {
                                Text(filterManager.colorLabels[filterManager.currentColorIndex])
                            }else {
                                Text("Color")
                                    .tint(.white)
                            }
                        }
                        Spacer()
                        
                        // 화면 비율 조정 버튼
                        Button(action: {
                            menuButtonAction(value: "Ratio")
                        }) {
                            Text(filterManager.ratioLabels[filterManager.currentRatioIndex])
                        }
                        Spacer()
                        
                        if filterManager.selectedImage == nil {
                            Button(action: {
                                model.feedback()
                                model.showGrid.toggle()
                            }) {
                                Text("Grid")
                                    .tint(model.showGrid ? .yellow : .white)
                            }
                            Spacer()
                            
                            Button(action: {
                                menuButtonAction(value: "Zoom")
                            }) {
                                Text(String(format: "x%.1f", cameraManager.currentZoomFactor))
                                    .tint(cameraManager.currentZoomFactor > 1.0 ? .yellow : .white)
                            }
                        }else {
                            Button(action: {
                                filterManager.selectedImage = filterManager.selectedImage?.rotated(byDegrees: 90)
                            }) {
                                Text("Rotate")
                            }
                        }
                    }
                }
                .padding()
                .multilineTextAlignment(.center)
                
                HStack {
                    Button(action: {
                        menuButtonAction(value: "Exposure")
                    }, label: {
                        Image(systemName: "rays")
                        Text(String(format: "%.1f", filterManager.exposureKeyValue))
                    })
                    .tint(filterManager.exposureKeyValue == 0.0 ? .white : .yellow)
                    Spacer()
                    
                    Button(action: {
                        menuButtonAction(value: "Sharpness")
                    }, label: {
                        Image(systemName: "triangle")
                        Text(String(format: "%.1f", filterManager.sharpnessKeyValue))
                    })
                    .tint(filterManager.sharpnessKeyValue == 0.0 ? .white : .yellow)
                    Spacer()
                    
                    Button(action: {
                        menuButtonAction(value: "Contrast")
                    }, label: {
                        Image(systemName: "circle.lefthalf.filled")
                        Text(String(format: "%.1f", ( filterManager.contrastKeyValue - 1) * 10))
                    })
                    .tint(filterManager.contrastKeyValue == 1.0 ? .white : .yellow)
                    Spacer()
                    
                    Button(action: {
                        menuButtonAction(value: "Saturation")
                    }, label: {
                        Image(systemName: "camera.filters")
                        Text(String(format: "%.1f", filterManager.saturationKeyValue))
                    })
                    .tint(filterManager.saturationKeyValue == 1.0 ? .white : .yellow)
                    Spacer()
                    
                    Button(action: {
                        menuButtonAction(value: "White Balance")
                    }, label: {
                        Image(systemName: "thermometer.medium")
                        Text(String(format: "%.1f", (filterManager.temperatureKeyValue - 6500) * 0.0005))
                    })
                    .tint(filterManager.temperatureKeyValue == 6500 ? .white : .yellow)
                }
                .font(.vcr16)
                .padding(.horizontal)
                
                // 컨트롤 뷰
                if model.showControlView {
                    ControlView(controlValue: model.controlValue)
                        .padding(.top)
                        .padding(.horizontal)
                }
            }
            
            if let selectedImage = filterManager.selectedImage?.cgImage {
                ImageView(image: filterManager.processImage(image: selectedImage))
                    .padding()
            } else if model.showFrameView && !model.isImagePickerPresented {
                FrameView(image: model.frame, showGrid: model.showGrid)
                    .blur(radius: model.isBlurred ? 20 : 0)
                    .rotation3DEffect(.degrees(model.flipEffect ? 0 : 180), axis: (x: 0, y: 1, z: 0))
                    .padding()
                // 확대/축소제스처로 줌인/아웃
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / self.model.lastScaleValue // 이전 스케일 대비 변화량 계산
                                CameraManager.shared.setZoomLevel(to: delta)
                                self.model.lastScaleValue = value // 마지막 스케일 값을 업데이트
                            }
                            .onEnded { _ in
                                self.model.lastScaleValue = 1.0 // 제스처가 끝나면 마지막 스케일 값을 리셋
                            }
                    )
                    .onTapGesture(count: 2) {
                        model.takePicture()
                    }
                    .onAppear {
                        DispatchQueue.global(qos: .userInitiated).async {
                            cameraManager.session.startRunning()
                        }
                    }
            }
            
            // 하단 UI
            
//            // 컨트롤 뷰
//            if model.showControlView {
//                ControlView(controlValue: model.controlValue)
//                    .padding()
//            }
            
            // 프리셋
            HStack {
                Text("Presets |")
                    .font(.vcr16)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(filterManager.presetLabels.indices, id: \.self) { index in
                            if index > 0 {
                                Button(action: {
                                    model.feedback()
                                    if filterManager.currentPresetIndex == index {
                                        filterManager.currentPresetIndex = 0
                                        filterManager.applyPreset()
                                    }else {
                                        filterManager.currentPresetIndex = index
                                        filterManager.applyPreset()
                                    }
                                }, label: {
                                    Text(filterManager.presetLabels[index])
                                        .foregroundColor(filterManager.currentPresetIndex == index ? .yellow : .white)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 1)
                                        .background(.black)
                                        .font(.vcr24)
                                })
                            }
                        }
                    }
                }
                .padding(.horizontal)
                Button(action: {
                    if filterManager.currentPresetIndex > 0 {
                        model.feedback()
                        model.savePreset(label: filterManager.presetLabels[filterManager.currentPresetIndex])
                    }
                }, label: {
                    Text("| Save")
                        .font(.vcr16)
                })
                .tint(filterManager.currentPresetIndex > 0 ? .yellow : .white)
                .disabled(filterManager.currentPresetIndex == 0)
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            HStack {
                // 카메라 앨범 버튼
                Button(action: {
                    model.feedback()
                    cameraManager.session.stopRunning()
                    model.isImagePickerPresented = true
                }) {
                    Text("Album")
                }
                .sheet(isPresented: $model.isImagePickerPresented) {
                    ImagePicker(selectedImage: $filterManager.selectedImage)
                }
                Spacer()
                // 사진찍기 버튼
                if let selectedImage = filterManager.selectedImage {
                    // 이미지 저장 버튼
                    Button(action: {
                        if let cgImage = selectedImage.cgImage {
                            if let processedImage = filterManager.processImage(image: cgImage) {
                                model.feedback()
                                model.saveImage(image: processedImage)
                            }
                        }
                    }) {
                        Text("Save")
                    }
                    
                    Spacer()
                    
                    // 이미지 선택 취소 버튼
                    Button(action: {
                        model.feedback()
                        filterManager.selectedImage = nil
                    }) {
                        Text("Cancel")
                    }
                } else {
                    // 사진찍기 버튼
                    Button(action: {
                        model.takePicture()
                    }) {
                        Text("Shutter")
                    }
                    Spacer()
                    // 카메라 전환 버튼
                    Button(action: {
                        if !model.isBusy {
                            model.isBusy = true
                            model.feedback()
                            // 블러 효과 적용
                            withAnimation(.easeInOut(duration: 0.1)) {
                                model.showFrameView = true
                                model.isBlurred = true
                            }
                            
                            // 카메라 전환 작업을 비동기로 수행 (여기서는 예시로 딜레이를 사용)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    model.showFrameView = false
                                }
                                model.flipEffect.toggle()
                                model.switchCamera()
                            }
                            
                            // 카메라 전환이 완료될 것으로 예상되는 시간 후에 블러 효과 해제
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                model.isBlurred = false
                                model.isBusy = false
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    model.showFrameView = true
                                }
                            }
                        }
                    }) {
                        Text(cameraManager.currentCameraPosition == .back ? " Rear" : "Front")
                    }
                }
            }
            .padding()
            .padding(.bottom, 30)
        }
    }
    
    func menuButtonAction(value: String) {
        model.feedback()
        if model.controlValue == value {
            model.showControlView.toggle()
        }else {
            model.controlValue = value
            model.showControlView = true
        }
    }
}
