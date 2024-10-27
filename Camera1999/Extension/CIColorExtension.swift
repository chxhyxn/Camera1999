//
//  CIColorExtension.swift
//  Camera1999
//
//  Created by Sean Cho on 4/6/24.
//

import SwiftUI
import UIKit

extension CIColor {
    convenience init(color: Color) {
        self.init(color: UIColor(color))
    }
}
