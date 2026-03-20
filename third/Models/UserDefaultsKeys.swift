//
//  UserDefaultsKeys.swift
//  third
//

import Foundation

enum UserDefaultsKey: String {
    // MARK: - User
    case userProfile = "userProfile"

    // MARK: - Settings
    case soundEffectsEnabled = "soundEffectsEnabled"
    case selectedLanguage = "selectedLanguage"

    // MARK: - Session
    case currentGameSession = "currentGameSession"

    // MARK: - Stats
    case gameHighScore = "gameHighScore"
    case furthestQuestionReached = "furthestQuestionReached"
    case totalGamesPlayed = "totalGamesPlayed"
    case totalScoreAccumulated = "totalScoreAccumulated"
    case longestStreak = "longestStreak"
    case statsChecksum = "statsChecksum"
}
