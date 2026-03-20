//
//  UserSettings.swift
//  third
//
//  Created by Berkay Akpınar on 19.03.2026.
//

import SwiftUI

enum AppLanguage: String, CaseIterable, Codable {
    case turkish = "tr"
    case english = "en"

    var displayName: String {
        switch self {
        case .turkish: return "Türkçe"
        case .english: return "English"
        }
    }

    var flag: String {
        switch self {
        case .turkish: return "🇹🇷"
        case .english: return "🇬🇧"
        }
    }
}

@Observable
class UserSettings {
    // MARK: - Sound Settings
    var soundEffectsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundEffectsEnabled, forKey: "soundEffectsEnabled")
        }
    }


    // MARK: - Language
    var selectedLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selectedLanguage")
        }
    }

    // MARK: - App Info
    let appVersion = "1.0.0"
    let developerName = "Berkay Akpınar"

    // MARK: - Init
    init() {
        // Load from UserDefaults or use defaults
        self.soundEffectsEnabled = UserDefaults.standard.object(forKey: "soundEffectsEnabled") as? Bool ?? true

        let languageRaw = UserDefaults.standard.string(forKey: "selectedLanguage") ?? AppLanguage.turkish.rawValue
        self.selectedLanguage = AppLanguage(rawValue: languageRaw) ?? .turkish
    }

    // MARK: - Reset
    func resetToDefaults() {
        soundEffectsEnabled = true
        selectedLanguage = .turkish
    }
}
