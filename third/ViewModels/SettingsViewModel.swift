//
//  SettingsViewModel.swift
//  third
//
//  Created by Berkay Akpınar on 19.03.2026.
//

import SwiftUI

@Observable
class SettingsViewModel {
    var settings: UserSettings
    var showResetConfirmation = false

    init() {
        self.settings = UserSettings()
    }

    func toggleSoundEffects() {
        settings.soundEffectsEnabled.toggle()
    }

    func toggleLanguage() {
        settings.selectedLanguage = settings.selectedLanguage == .turkish ? .english : .turkish
        // Dil değiştiğinde soruları yeniden yükle
        GameData.reload()
    }
}
