//
//  AppStrings.swift
//  third
//
//  Centralized UI strings for Turkish and English.
//  Use via: AppStrings.xxx(for: language)
//

import Foundation

enum AppStrings {
    // MARK: - Main Menu
    static func continueGame(for lang: AppLanguage) -> String {
        lang == .english ? "Continue" : "Devam Et"
    }
    static func newGame(for lang: AppLanguage) -> String {
        lang == .english ? "New Game" : "Yeni Oyun"
    }
    static func profile(for lang: AppLanguage) -> String {
        lang == .english ? "Profile" : "Profil"
    }
    static func settings(for lang: AppLanguage) -> String {
        lang == .english ? "Settings" : "Ayarlar"
    }

    // MARK: - Game
    static func nextQuestion(for lang: AppLanguage) -> String {
        lang == .english ? "Next Question" : "Sıradaki Soru"
    }

    // MARK: - Game Over
    static func gameOver(for lang: AppLanguage) -> String {
        lang == .english ? "GAME OVER!" : "OYUN BİTTİ!"
    }
    static func score(for lang: AppLanguage) -> String {
        lang == .english ? "SCORE" : "SKOR"
    }
    static func best(for lang: AppLanguage) -> String {
        lang == .english ? "Best:" : "En Yüksek:"
    }
    static func playAgain(for lang: AppLanguage) -> String {
        lang == .english ? "Play Again" : "Tekrar Oyna"
    }

    // MARK: - Profile
    static func edit(for lang: AppLanguage) -> String {
        lang == .english ? "Edit" : "Düzenle"
    }
    static func highScore(for lang: AppLanguage) -> String {
        lang == .english ? "High Score" : "En Yüksek Skor"
    }
    static func furthestQuestion(for lang: AppLanguage) -> String {
        lang == .english ? "Furthest Question" : "En Uzak Soru"
    }
    static func totalGames(for lang: AppLanguage) -> String {
        lang == .english ? "Total Games" : "Toplam Oyun"
    }
    static func averageScore(for lang: AppLanguage) -> String {
        lang == .english ? "Average Score" : "Ortalama Skor"
    }
    static func longestStreak(for lang: AppLanguage) -> String {
        lang == .english ? "Longest Streak" : "En Uzun Seri"
    }
    static func resetStats(for lang: AppLanguage) -> String {
        lang == .english ? "Reset Stats" : "İstatistik Sıfırla"
    }
    static func resetStatsConfirmTitle(for lang: AppLanguage) -> String {
        lang == .english ? "Reset Statistics?" : "İstatistikleri Sıfırla?"
    }
    static func resetStatsConfirmMessage(for lang: AppLanguage) -> String {
        lang == .english ? "This action cannot be undone." : "Bu işlem geri alınamaz."
    }
    static func reset(for lang: AppLanguage) -> String {
        lang == .english ? "Reset" : "Sıfırla"
    }
    static func cancel(for lang: AppLanguage) -> String {
        lang == .english ? "Cancel" : "İptal"
    }

    // MARK: - Settings
    static func settingsTitle(for lang: AppLanguage) -> String {
        lang == .english ? "Settings" : "Ayarlar"
    }
    static func soundEffects(for lang: AppLanguage) -> String {
        lang == .english ? "Sound Effects" : "Ses Efektleri"
    }
    static func soundEffectsDescription(for lang: AppLanguage) -> String {
        lang == .english ? "Toggle in-game sounds" : "Oyun içi sesleri aç/kapat"
    }
    static func language(for lang: AppLanguage) -> String {
        lang == .english ? "Language" : "Dil Seçeneği"
    }
    static func version(for lang: AppLanguage) -> String {
        lang == .english ? "Version" : "Sürüm"
    }
    static func resetToDefaults(for lang: AppLanguage) -> String {
        lang == .english ? "Reset to Defaults" : "Varsayılan Ayarlara Dön"
    }
    static func resetSettingsConfirmTitle(for lang: AppLanguage) -> String {
        lang == .english ? "Reset Settings?" : "Ayarları Sıfırla?"
    }
    static func resetSettingsConfirmMessage(for lang: AppLanguage) -> String {
        lang == .english ? "All settings will be restored to defaults." : "Tüm ayarlar varsayılan değerlere dönecek. Emin misiniz?"
    }

    // MARK: - Username Edit Sheet
    static func editName(for lang: AppLanguage) -> String {
        lang == .english ? "Edit Name" : "İsim Düzenle"
    }
    static func maxCharacters(for lang: AppLanguage) -> String {
        lang == .english ? "Maximum 20 characters" : "Maksimum 20 karakter"
    }
    static func usernamePlaceholder(for lang: AppLanguage) -> String {
        lang == .english ? "Username" : "Kullanıcı adı"
    }
    static func save(for lang: AppLanguage) -> String {
        lang == .english ? "Save" : "Kaydet"
    }
}
