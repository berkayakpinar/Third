//
//  StatsManaging.swift
//  third
//
//  Protocol that abstracts stats persistence.
//  GameViewModel depends on this — not on the concrete GameStatsManager class.
//  This makes score saving fully testable with a MockStatsManager.
//

import Foundation

protocol StatsManaging: AnyObject {
    var highScore: Int { get }
    var furthestQuestion: Int { get }
    var totalGamesPlayed: Int { get }
    var totalScoreAccumulated: Int { get }
    var longestStreak: Int { get }
    var averageScore: Int { get }

    func saveGameResult(score: Int, questionIndex: Int, currentStreak: Int)
    func resetStats()
}

extension StatsManaging {
    /// Convenience overload — currentStreak defaults to 0.
    func saveGameResult(score: Int, questionIndex: Int) {
        saveGameResult(score: score, questionIndex: questionIndex, currentStreak: 0)
    }
}
