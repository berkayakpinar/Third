//
//  SettingsViewModel.swift
//  third
//
//  Created by Berkay Akpınar on 19.03.2026.
//

import SwiftUI

@Observable
class SettingsViewModel {
    var showResetConfirmation = false

    private let questionProvider: QuestionProviding

    init(questionProvider: QuestionProviding = GameData.shared) {
        self.questionProvider = questionProvider
    }

    func toggleSoundEffects(settings: UserSettings) {
        settings.soundEffectsEnabled.toggle()
    }

    func toggleLanguage(settings: UserSettings) {
        settings.selectedLanguage = settings.selectedLanguage == .turkish ? .english : .turkish
        questionProvider.load(force: true)
    }
}
