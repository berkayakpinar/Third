//
//  ProfileViewModel.swift
//  third
//
//  Created by Claude on 19.03.2026.
//

import Foundation

@Observable
class ProfileViewModel {
    private let statsManager: GameStatsManager

    var userProfile: UserProfile

    var highScore: Int { statsManager.highScore }
    var furthestQuestion: Int { statsManager.furthestQuestion }
    var totalGamesPlayed: Int { statsManager.totalGamesPlayed }
    var averageScore: Int { statsManager.averageScore }
    var longestStreak: Int { statsManager.longestStreak }

    var username: String { userProfile.username }

    var isEditingUsername = false
    var usernameInput = ""

    init(statsManager: GameStatsManager = .shared) {
        self.statsManager = statsManager
        self.userProfile = UserProfile.load()
        self.usernameInput = userProfile.username
    }

    // MARK: - Username Actions

    func startEditingUsername() {
        usernameInput = userProfile.username
        isEditingUsername = true
    }

    func saveUsername() {
        let trimmed = usernameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty && trimmed.count <= 20 else { return }

        userProfile.username = trimmed
        userProfile.save()
        isEditingUsername = false
    }

    func cancelEditingUsername() {
        usernameInput = userProfile.username
        isEditingUsername = false
    }

    // MARK: - Stats Actions

    func resetStats() {
        statsManager.resetStats()
    }
}
