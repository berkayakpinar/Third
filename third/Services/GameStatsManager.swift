//
//  GameStatsManager.swift
//  third
//
//  Created by Berkay Akpınar on 19.03.2026.
//

import Foundation

@Observable
class GameStatsManager {
    static let shared = GameStatsManager()

    private let userDefaults = UserDefaults.standard
    private let highScoreKey = "gameHighScore"
    private let furthestQuestionKey = "furthestQuestionReached"
    private let totalGamesPlayedKey = "totalGamesPlayed"
    private let totalScoreAccumulatedKey = "totalScoreAccumulated"
    private let longestStreakKey = "longestStreak"

    private(set) var highScore: Int = 0
    private(set) var furthestQuestion: Int = 0
    private(set) var totalGamesPlayed: Int = 0
    private(set) var totalScoreAccumulated: Int = 0
    private(set) var longestStreak: Int = 0

    /// Computed property for average score
    var averageScore: Int {
        totalGamesPlayed > 0 ? totalScoreAccumulated / totalGamesPlayed : 0
    }

    private init() {
        loadStats()
    }

    // MARK: - Public Methods

    /// Saves the result of a completed game and updates high scores if necessary
    func saveGameResult(score: Int, questionIndex: Int, currentStreak: Int = 0) {
        // Update high score if current score is higher
        if score > highScore {
            highScore = score
            userDefaults.set(highScore, forKey: highScoreKey)
        }

        // Update furthest question reached if current is higher
        if questionIndex > furthestQuestion {
            furthestQuestion = questionIndex
            userDefaults.set(furthestQuestion, forKey: furthestQuestionKey)
        }

        // Update total games played
        totalGamesPlayed += 1
        userDefaults.set(totalGamesPlayed, forKey: totalGamesPlayedKey)

        // Update total score accumulated (for average calculation)
        totalScoreAccumulated += score
        userDefaults.set(totalScoreAccumulated, forKey: totalScoreAccumulatedKey)

        // Update longest streak if current is higher
        if currentStreak > longestStreak {
            longestStreak = currentStreak
            userDefaults.set(longestStreak, forKey: longestStreakKey)
        }
    }

    /// Resets all stats
    func resetStats() {
        highScore = 0
        furthestQuestion = 0
        totalGamesPlayed = 0
        totalScoreAccumulated = 0
        longestStreak = 0

        userDefaults.removeObject(forKey: highScoreKey)
        userDefaults.removeObject(forKey: furthestQuestionKey)
        userDefaults.removeObject(forKey: totalGamesPlayedKey)
        userDefaults.removeObject(forKey: totalScoreAccumulatedKey)
        userDefaults.removeObject(forKey: longestStreakKey)
    }

    // MARK: - Private Methods

    private func loadStats() {
        highScore = userDefaults.integer(forKey: highScoreKey)
        furthestQuestion = userDefaults.integer(forKey: furthestQuestionKey)
        totalGamesPlayed = userDefaults.integer(forKey: totalGamesPlayedKey)
        totalScoreAccumulated = userDefaults.integer(forKey: totalScoreAccumulatedKey)
        longestStreak = userDefaults.integer(forKey: longestStreakKey)
    }
}
