//
//  GameStatsManagerTests.swift
//  thirdTests
//
//  Each test gets an isolated UserDefaults suite so tests never interfere.
//

import Testing
import Foundation
@testable import third

// MARK: - Helpers

private func makeManager() -> GameStatsManager {
    // Each call creates a fresh, empty UserDefaults suite
    let suite = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
    return GameStatsManager(userDefaults: suite)
}

// MARK: - Suite

@Suite("GameStatsManager")
struct GameStatsManagerTests {

    // MARK: - Initial state

    @Test func initialState_allZero() {
        let manager = makeManager()
        #expect(manager.highScore == 0)
        #expect(manager.furthestQuestion == 0)
        #expect(manager.totalGamesPlayed == 0)
        #expect(manager.totalScoreAccumulated == 0)
        #expect(manager.longestStreak == 0)
        #expect(manager.averageScore == 0)
    }

    // MARK: - saveGameResult

    @Test func saveGameResult_updatesHighScore() {
        let manager = makeManager()
        manager.saveGameResult(score: 500, questionIndex: 3, currentStreak: 0)
        #expect(manager.highScore == 500)
    }

    @Test func saveGameResult_doesNotLowerHighScore() {
        let manager = makeManager()
        manager.saveGameResult(score: 500, questionIndex: 3, currentStreak: 0)
        manager.saveGameResult(score: 200, questionIndex: 1, currentStreak: 0)
        #expect(manager.highScore == 500)
    }

    @Test func saveGameResult_updatesFurthestQuestion() {
        let manager = makeManager()
        manager.saveGameResult(score: 100, questionIndex: 7, currentStreak: 0)
        #expect(manager.furthestQuestion == 7)
    }

    @Test func saveGameResult_doesNotLowerFurthestQuestion() {
        let manager = makeManager()
        manager.saveGameResult(score: 100, questionIndex: 7, currentStreak: 0)
        manager.saveGameResult(score: 100, questionIndex: 2, currentStreak: 0)
        #expect(manager.furthestQuestion == 7)
    }

    @Test func saveGameResult_incrementsTotalGamesPlayed() {
        let manager = makeManager()
        manager.saveGameResult(score: 100, questionIndex: 1, currentStreak: 0)
        manager.saveGameResult(score: 200, questionIndex: 2, currentStreak: 0)
        #expect(manager.totalGamesPlayed == 2)
    }

    @Test func saveGameResult_accumulatesTotalScore() {
        let manager = makeManager()
        manager.saveGameResult(score: 100, questionIndex: 1, currentStreak: 0)
        manager.saveGameResult(score: 200, questionIndex: 2, currentStreak: 0)
        #expect(manager.totalScoreAccumulated == 300)
    }

    @Test func averageScore_calculatedCorrectly() {
        let manager = makeManager()
        manager.saveGameResult(score: 100, questionIndex: 1, currentStreak: 0)
        manager.saveGameResult(score: 300, questionIndex: 2, currentStreak: 0)
        // average = 400 / 2 = 200
        #expect(manager.averageScore == 200)
    }

    @Test func saveGameResult_updatesLongestStreak() {
        let manager = makeManager()
        manager.saveGameResult(score: 100, questionIndex: 1, currentStreak: 5)
        #expect(manager.longestStreak == 5)
    }

    @Test func saveGameResult_doesNotLowerLongestStreak() {
        let manager = makeManager()
        manager.saveGameResult(score: 100, questionIndex: 1, currentStreak: 5)
        manager.saveGameResult(score: 200, questionIndex: 2, currentStreak: 2)
        #expect(manager.longestStreak == 5)
    }

    // MARK: - resetStats

    @Test func resetStats_resetsAllToZero() {
        let manager = makeManager()
        manager.saveGameResult(score: 500, questionIndex: 10, currentStreak: 3)
        manager.resetStats()

        #expect(manager.highScore == 0)
        #expect(manager.furthestQuestion == 0)
        #expect(manager.totalGamesPlayed == 0)
        #expect(manager.totalScoreAccumulated == 0)
        #expect(manager.longestStreak == 0)
    }

    @Test func resetStats_allowsSavingAfterReset() {
        let manager = makeManager()
        manager.saveGameResult(score: 500, questionIndex: 10, currentStreak: 3)
        manager.resetStats()
        manager.saveGameResult(score: 150, questionIndex: 4, currentStreak: 0)

        #expect(manager.highScore == 150)
        #expect(manager.totalGamesPlayed == 1)
    }

    // MARK: - Persistence

    @Test func saveGameResult_persistsAcrossReinit() {
        let suiteName = "test-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!

        let manager1 = GameStatsManager(userDefaults: defaults)
        manager1.saveGameResult(score: 750, questionIndex: 5, currentStreak: 0)

        // Simulate app relaunch — new instance, same suite
        let manager2 = GameStatsManager(userDefaults: defaults)
        #expect(manager2.highScore == 750)
        #expect(manager2.furthestQuestion == 5)
    }
}
