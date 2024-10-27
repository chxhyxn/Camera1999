//
//  Camera1999App.swift
//  Camera1999
//
//  Created by Sean Cho on 4/5/24.
//

import SwiftUI

@main
struct Camera1999App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(.yellow)
                .preferredColorScheme(.dark)
                .font(.vcr20)
                .statusBar(hidden: true)
//                .ignoresSafeArea(.all)
        }
    }
}
