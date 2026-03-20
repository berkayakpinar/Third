//
//  MockStatsManager.swift
//  thirdTests
//

import Foundation
@testable import third

// MARK: - MockStatsManager

final class MockStatsManager: StatsManaging {

    // MARK: - StatsManaging

    var highScore: Int = 0
    var furthestQuestion: Int = 0
    var totalGamesPlayed: Int = 0
    var totalScoreAccumulated: Int = 0
    var longestStreak: Int = 0
    var averageScore: Int { totalGamesPlayed > 0 ? totalScoreAccumulated / totalGamesPlayed : 0 }

    // MARK: - Tracking

    struct SaveCall {
        let score: Int
        let questionIndex: Int
        let currentStreak: Int
    }

    var saveCalls: [SaveCall] = []
    var resetCalled = false

    // MARK: - StatsManaging Methods

    func saveGameResult(score: Int, questionIndex: Int, currentStreak: Int) {
        saveCalls.append(SaveCall(score: score, questionIndex: questionIndex, currentStreak: currentStreak))
        if score > highScore { highScore = score }
        if questionIndex > furthestQuestion { furthestQuestion = questionIndex }
        totalGamesPlayed += 1
        totalScoreAccumulated += score
    }

    func resetStats() {
        resetCalled = true
        highScore = 0
        furthestQuestion = 0
        totalGamesPlayed = 0
        totalScoreAccumulated = 0
        longestStreak = 0
    }
}
