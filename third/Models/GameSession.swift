//
//  GameSession.swift
//  third
//
//  Created by Berkay Akpınar on 18.03.2026.
//

import Foundation

struct GameSession: Codable {
    var gameState: GameState
    var currentQuestionIndex: Int
    var questionStates: [QuestionState]
    var timestamp: Date
    var isNewGame: Bool

    var isActive: Bool {
        gameState.lives > 0
    }
}

struct QuestionState: Codable {
    var text: String
    var revealedAnswers: Set<Int>

    init(text: String, revealedAnswers: Set<Int> = []) {
        self.text = text
        self.revealedAnswers = revealedAnswers
    }
}
