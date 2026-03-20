//
//  GameData.swift
//  third
//
//  Created by Berkay Akpınar on 12.03.2026.
//

import Foundation

enum GameData {
    // MARK: - Question Bank
    private static var questions: [GameQuestion] = []
    private static var currentLanguage: AppLanguage = .turkish

    // MARK: - Used Questions Tracking
    private static var usedQuestionIndices: Set<Int> = []

    // MARK: - Load Questions from JSON
    static func load() {
        let userSettings = UserSettings()
        let language = userSettings.selectedLanguage

        // Dil değiştiyse soruları yeniden yükle
        if language != currentLanguage || questions.isEmpty {
            currentLanguage = language
            do {
                questions = try QuestionLoader.loadQuestions(for: language)
                print("✅ Loaded \(questions.count) questions for \(language.displayName)")
            } catch {
                print("❌ Failed to load questions: \(error.localizedDescription)")
                questions = []
            }
        }
    }

    // MARK: - Force reload (dil değiştiğinde çağrılır)
    static func reload() {
        currentLanguage = .turkish // Farklı dil gibi görünsün diye
        load()
    }

    // MARK: - Get Next Question
    static func getNextQuestion() -> GameQuestion {
        // Fallback soru - JSON yüklenemezse kullanılır
        let fallbackQuestion = GameQuestion(
            id: 0,
            text: "Sorular yüklenemedi. Lütfen uygulamayı yeniden başlatın.",
            answers: [
                AnswerOption(keywords: ["hata"], displayWord: "Hata", type: .trap),
                AnswerOption(keywords: ["yükle"], displayWord: "Yükle", type: .normal),
                AnswerOption(keywords: ["tekrar"], displayWord: "Tekrar", type: .target),
                AnswerOption(keywords: ["başlat"], displayWord: "Başlat", type: .normal),
                AnswerOption(keywords: ["uygulama"], displayWord: "Uygulama", type: .normal)
            ]
        )

        guard !questions.isEmpty else {
            print("Warning: No questions loaded! Using fallback.")
            return fallbackQuestion
        }

        // Find available questions (not used yet)
        let availableIndices = questions.indices.filter { !usedQuestionIndices.contains($0) }

        // If all questions used, reset and start over
        if availableIndices.isEmpty {
            usedQuestionIndices.removeAll()
            return questions.randomElement() ?? fallbackQuestion
        }

        // Get random question from available ones
        guard let randomIndex = availableIndices.randomElement() else {
            return fallbackQuestion
        }
        usedQuestionIndices.insert(randomIndex)
        return questions[randomIndex]
    }

    // MARK: - Reset
    static func resetProgress() {
        usedQuestionIndices.removeAll()
    }
}
