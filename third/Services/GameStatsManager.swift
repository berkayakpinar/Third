//
//  GameStatsManager.swift
//  third
//
//  Created by Berkay Akpınar on 19.03.2026.
//

import Foundation
import CryptoKit
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "third", category: "GameStatsManager")

@Observable
class GameStatsManager: StatsManaging {
    static let shared = GameStatsManager()

    private let userDefaults: UserDefaults
    private let highScoreKey = UserDefaultsKey.gameHighScore.rawValue
    private let furthestQuestionKey = UserDefaultsKey.furthestQuestionReached.rawValue
    private let totalGamesPlayedKey = UserDefaultsKey.totalGamesPlayed.rawValue
    private let totalScoreAccumulatedKey = UserDefaultsKey.totalScoreAccumulated.rawValue
    private let longestStreakKey = UserDefaultsKey.longestStreak.rawValue
    private let checksumKey = UserDefaultsKey.statsChecksum.rawValue

    private(set) var highScore: Int = 0
    private(set) var furthestQuestion: Int = 0
    private(set) var totalGamesPlayed: Int = 0
    private(set) var totalScoreAccumulated: Int = 0
    private(set) var longestStreak: Int = 0

    var averageScore: Int {
        totalGamesPlayed > 0 ? totalScoreAccumulated / totalGamesPlayed : 0
    }

    private init() {
        self.userDefaults = .standard
        loadStats()
    }

    /// Designated init for testing — pass a suiteName-based UserDefaults for isolation.
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        loadStats()
    }

    // MARK: - Public Methods

    func saveGameResult(score: Int, questionIndex: Int, currentStreak: Int = 0) {
        if score > highScore {
            highScore = score
            userDefaults.set(highScore, forKey: highScoreKey)
        }
        if questionIndex > furthestQuestion {
            furthestQuestion = questionIndex
            userDefaults.set(furthestQuestion, forKey: furthestQuestionKey)
        }
        totalGamesPlayed += 1
        userDefaults.set(totalGamesPlayed, forKey: totalGamesPlayedKey)

        totalScoreAccumulated += score
        userDefaults.set(totalScoreAccumulated, forKey: totalScoreAccumulatedKey)

        if currentStreak > longestStreak {
            longestStreak = currentStreak
            userDefaults.set(longestStreak, forKey: longestStreakKey)
        }

        saveChecksum()
    }

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
        userDefaults.removeObject(forKey: checksumKey)
    }

    // MARK: - Private Methods

    private func loadStats() {
        let stored = (
            highScore:            userDefaults.integer(forKey: highScoreKey),
            furthestQuestion:     userDefaults.integer(forKey: furthestQuestionKey),
            totalGamesPlayed:     userDefaults.integer(forKey: totalGamesPlayedKey),
            totalScoreAccumulated: userDefaults.integer(forKey: totalScoreAccumulatedKey),
            longestStreak:        userDefaults.integer(forKey: longestStreakKey)
        )

        let storedChecksum = userDefaults.string(forKey: checksumKey) ?? ""
        let expectedChecksum = computeChecksum(
            stored.highScore,
            stored.furthestQuestion,
            stored.totalGamesPlayed,
            stored.totalScoreAccumulated,
            stored.longestStreak
        )

        // If checksum doesn't exist yet (fresh install / migration), accept and save it
        if storedChecksum.isEmpty {
            highScore            = stored.highScore
            furthestQuestion     = stored.furthestQuestion
            totalGamesPlayed     = stored.totalGamesPlayed
            totalScoreAccumulated = stored.totalScoreAccumulated
            longestStreak        = stored.longestStreak
            saveChecksum()
            return
        }

        guard storedChecksum == expectedChecksum else {
            logger.error("Stats checksum mismatch — data may have been tampered with. Resetting stats.")
            resetStats()
            return
        }

        highScore            = stored.highScore
        furthestQuestion     = stored.furthestQuestion
        totalGamesPlayed     = stored.totalGamesPlayed
        totalScoreAccumulated = stored.totalScoreAccumulated
        longestStreak        = stored.longestStreak
    }

    private func saveChecksum() {
        let checksum = computeChecksum(
            highScore, furthestQuestion, totalGamesPlayed, totalScoreAccumulated, longestStreak
        )
        userDefaults.set(checksum, forKey: checksumKey)
    }

    /// SHA256 hash of all stat values joined by commas.
    private func computeChecksum(_ values: Int...) -> String {
        let input = values.map { String($0) }.joined(separator: ",")
        let digest = SHA256.hash(data: Data(input.utf8))
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}
