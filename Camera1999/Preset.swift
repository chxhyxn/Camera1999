//
//  Preset.swift
//  Camera1999
//
//  Created by Sean Cho on 4/8/24.
//

import Foundation

class Preset: Codable {
    var filmIndex: Int
    var colorIndex: Int
    var exposureKeyValue: Double
    var sharpnessKeyValue: Double
    var contrastKeyValue: Double
    var saturationKeyValue: Double
    var temperatureKeyValue: Double

    init(filmIndex: Int, colorIndex: Int, exposureKeyValue: Double, sharpnessKeyValue: Double, contrastKeyValue: Double, saturationKeyValue: Double, temperatureKeyValue: Double) {
        self.filmIndex = filmIndex
        self.colorIndex = colorIndex
        self.exposureKeyValue = exposureKeyValue
        self.sharpnessKeyValue = sharpnessKeyValue
        self.contrastKeyValue = contrastKeyValue
        self.saturationKeyValue = saturationKeyValue
        self.temperatureKeyValue = temperatureKeyValue
    }

    private enum CodingKeys: String, CodingKey {
        case filmIndex, colorIndex, exposureKeyValue, sharpnessKeyValue, contrastKeyValue, saturationKeyValue, temperatureKeyValue
    }
    
    // UserDefaults에 Preset 저장
    static func save(preset: Preset, with key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(preset) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    // UserDefaults에서 Preset 불러오기
    static func load(from key: String) -> Preset? {
        if let savedPreset = UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let loadedPreset = try? decoder.decode(Preset.self, from: savedPreset) {
                return loadedPreset
            }
        }
        return nil
    }
}
