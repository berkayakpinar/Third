//
//  thirdApp.swift
//  third
//
//  Created by Berkay Akpınar on 12.03.2026.
//

import SwiftUI

@main
struct thirdApp: App {
    @State private var sessionManager = SessionManager.shared

    var body: some Scene {
        WindowGroup {
            MainMenuView()
                .environment(sessionManager)
                .onAppear {
                    GameData.load()
                }
        }
    }
}
