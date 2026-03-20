//
//  GameViewModelTypes.swift
//  third
//
//  Plain value types used by GameViewModel and GameView.
//  Kept in a Foundation-only file so they have no implicit @MainActor isolation
//  and can be used freely in unit tests (Swift 6 compatible).
//

import Foundation

// MARK: - Game View Status

enum GameViewStatus: Equatable {
    case playing
    case questionWon
    case lost
}

// MARK: - Animation Signal

enum GameAnimationEvent: Equatable {
    case trap
    case target
    case wrongAnswer
    case nextQuestion
}

/// Wraps an animation event with a monotonically increasing ID so the same
/// event type can fire twice in a row and still trigger `.onChange`.
struct AnimationSignal: Equatable {
    let id: Int
    let event: GameAnimationEvent
}

// MARK: - Scoring Configuration

struct ScoringConfig {
    /// Base scores indexed by lives used: [0 lives, 1 life, 2 lives, 3+ lives]
    static let baseScores = [300, 200, 100, 0]
    /// Score multiplier added per question (10% per question)
    static let multiplierPerQuestion: Double = 0.1
}
