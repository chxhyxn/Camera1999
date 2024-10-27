//
//  CornerGridPattern.swift
//  Camera1999
//
//  Created by Sean Cho on 4/5/24.
//

import Foundation
import SwiftUI

struct CornerGridPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // 상단 왼쪽 모서리
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + 30))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + 30, y: rect.minY))
        
        // 상단 오른쪽 모서리
        path.move(to: CGPoint(x: rect.maxX - 30, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + 30))
        
        // 하단 왼쪽 모서리
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY - 30))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + 30, y: rect.maxY))
        
        // 하단 오른쪽 모서리
        path.move(to: CGPoint(x: rect.maxX - 30, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 30))
        
        return path
    }
}
