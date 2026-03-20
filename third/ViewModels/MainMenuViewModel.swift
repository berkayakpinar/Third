//
//  MainMenuViewModel.swift
//  third
//
//  Created by Berkay Akpınar on 18.03.2026.
//

import Foundation

@Observable
class MainMenuViewModel {
    private let sessionManager: SessionManager

    var canContinueGame: Bool {
        sessionManager.hasActiveSession
    }

    init(sessionManager: SessionManager = .shared) {
        self.sessionManager = sessionManager
    }

    func startNewGame() -> GameSession {
        sessionManager.startNewGame()
    }

    func continueGame() -> GameSession? {
        sessionManager.currentSession
    }
}
