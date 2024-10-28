//
//  ControlView.swift
//  Camera1999
//
//  Created by Sean Cho on 4/7/24.
//

import SwiftUI

struct ControlView: View {
    var controlValue: String
    @ObservedObject private var filterManager = FilterManager.shared
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    @State private var selectedColor: Color = .clear
    
    var body: some View {
        HStack {
            Text(controlValue + " |")
                .font(.vcr16)
            
            if controlValue == "Film" {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(filterManager.filmLabels.indices, id: \.self) { index in
                            Button(action: {
                                feedbackGenerator.impactOccurred()
                                if filterManager.currentFilmIndex == index {
                                    filterManager.currentFilmIndex = 0
                                }else {
                                    filterManager.currentFilmIndex = index
                                }
                            }, label: {
                                Text(filterManager.filmLabels[index])
                                    .foregroundColor(filterManager.currentFilmIndex == index ? .yellow : .white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 10)
                                    .background(.black)
                            })
                        }
                    }
                }
                .padding(.vertical, 7)
            }else if controlValue == "Color" {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(filterManager.colorLabels.indices, id: \.self) { index in
                            Button(action: {
                                feedbackGenerator.impactOccurred()
                                if filterManager.currentColorIndex == index {
                                    filterManager.currentColorIndex = 0
                                }else {
                                    filterManager.currentColorIndex = index
                                }
                            }, label: {
                                Text(filterManager.colorLabels[index])
                                    .foregroundColor(filterManager.currentColorIndex == index ? .yellow : .white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 10)
                                    .background(.black)
                            })
                        }
                    }
                }
                .padding(.vertical, 7)
            }else if controlValue == "Ratio" {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(filterManager.ratioLabels.indices, id: \.self) { index in
                            Button(action: {
                                feedbackGenerator.impactOccurred()
                                if filterManager.currentRatioIndex == index {
                                    filterManager.currentRatioIndex = 0
                                }else {
                                    filterManager.currentRatioIndex = index
                                }
                            }, label: {
                                Text(filterManager.ratioLabels[index])
                                    .foregroundColor(filterManager.currentFilmIndex == index ? .yellow : .white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 10)
                                    .background(filterManager.currentRatioIndex == index ? Color.black.opacity(0.7) : Color.black.opacity(0.5))
                            })
                        }
                    }
                }
                .padding(.vertical, 7)
            }else if controlValue == "Zoom" {
                Text("Pinch in/out on the screen.")
                    .padding(.vertical, 7)
            }else if controlValue == "Exposure" {
                Slider(value: $filterManager.exposureKeyValue, in: -1...1, step: 0.1)
//                    .onChange(of: filterManager.exposureKeyValue, {
//                        feedbackGenerator.impactOccurred(intensity: 0.5)
//                    })
            }else if controlValue == "Sharpness" {
                Slider(value: $filterManager.sharpnessKeyValue, in: -1...1, step: 0.1)
//                    .onChange(of: filterManager.sharpnessKeyValue, {
//                        feedbackGenerator.impactOccurred(intensity: 0.5)
//                    })
            }else if controlValue == "Contrast" {
                Slider(value: $filterManager.contrastKeyValue, in: 0.9...1.1, step: 0.01)
//                    .onChange(of: filterManager.contrastKeyValue, {
//                        feedbackGenerator.impactOccurred(intensity: 0.5)
//                    })
            }else if controlValue == "Saturation" {
                Slider(value: $filterManager.saturationKeyValue, in: 0.0...2.0, step: 0.1)
//                    .onChange(of: filterManager.saturationKeyValue, {
//                        feedbackGenerator.impactOccurred(intensity: 0.5)
//                    })
            }else if controlValue == "White Balance" {
                Slider(value: $filterManager.temperatureKeyValue, in: 4500...8500, step: 200)
//                    .onChange(of: filterManager.temperatureKeyValue, {
//                        feedbackGenerator.impactOccurred(intensity: 0.5)
//                    })
            }
            Spacer()
        }.onAppear {
            let thumbImage = UIImage(systemName: "placeholdertext.fill")
            UISlider.appearance().setThumbImage(thumbImage, for: .normal)
        }
    }
}
