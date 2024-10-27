//
//  GridPattern.swift
//  Camera1999
//
//  Created by Sean Cho on 4/5/24.
//

import Foundation
import SwiftUI

struct GridPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cellWidth = rect.width / 3
        let cellHeight = rect.height / 3
        
        // 중앙을 제외한 8개의 셀을 그립니다.
        for i in 0..<3 {
            for j in 0..<3 {
                // 중앙 셀은 제외
                if !(i == 1 && j == 1) {
                    let startX = CGFloat(i) * cellWidth
                    let startY = CGFloat(j) * cellHeight
                    
                    // 각 셀의 왼쪽 상단에서 시작
                    let rect = CGRect(x: startX, y: startY, width: cellWidth, height: cellHeight)
                    
                    // 셀을 경계로 하여 사각형 추가
                    path.addRect(rect)
                }
            }
        }
        
        return path
    }
}
