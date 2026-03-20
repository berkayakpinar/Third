//
//  GameData.swift
//  third
//
//  Converted from a static enum to a class so it can:
//    • Conform to QuestionProviding for dependency injection
//    • Be replaced with a MockQuestionProvider in tests
//

import Foundation
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "third", category: "GameData")

// MARK: - GameData

final class GameData: QuestionProviding {

    // MARK: - Singleton (production default)
    static let shared = GameData()

    // MARK: - Private State
    private var questions: [GameQuestion] = []
    private var currentLanguage: AppLanguage = .turkish
    private var usedQuestionIndices: Set<Int> = []

    private init() {}

    // MARK: - QuestionProviding

    /// Loads questions for the active language.
    /// Pass `force: true` to reload after a language change.
    func load(force: Bool = false) {
        let userSettings = UserSettings()
        let language = userSettings.selectedLanguage

        guard force || language != currentLanguage || questions.isEmpty else { return }

        currentLanguage = language
        do {
            questions = try QuestionLoader.loadQuestions(for: language)
            logger.info("Loaded \(self.questions.count) questions for \(language.displayName)")
        } catch {
            questions = []
            logger.error("Failed to load questions: \(error.localizedDescription)")
            assertionFailure("Question loading failed — check that \(language.rawValue).json exists in the bundle.")
        }
    }

    /// Returns the next question, skipping recently used ones.
    func getNextQuestion() -> GameQuestion {
        let fallback = makeFallbackQuestion()

        guard !questions.isEmpty else {
            logger.warning("No questions loaded, returning fallback.")
            return fallback
        }

        let availableIndices = questions.indices.filter { !usedQuestionIndices.contains($0) }

        if availableIndices.isEmpty {
            usedQuestionIndices.removeAll()
            return questions.randomElement() ?? fallback
        }

        guard let randomIndex = availableIndices.randomElement() else { return fallback }
        usedQuestionIndices.insert(randomIndex)
        return questions[randomIndex]
    }

    /// Resets the used-questions tracker so all questions become available again.
    func resetProgress() {
        usedQuestionIndices.removeAll()
    }

    // MARK: - Private

    private func makeFallbackQuestion() -> GameQuestion {
        switch currentLanguage {
        case .english:
            return GameQuestion(
                id: 0,
                text: "Questions could not be loaded. Please restart the app.",
                answers: [
                    AnswerOption(keywords: ["error"],  displayWord: "Error",  type: .trap),
                    AnswerOption(keywords: ["load"],   displayWord: "Load",   type: .normal),
                    AnswerOption(keywords: ["retry"],  displayWord: "Retry",  type: .target),
                    AnswerOption(keywords: ["start"],  displayWord: "Start",  type: .normal),
                    AnswerOption(keywords: ["app"],    displayWord: "App",    type: .normal)
                ]
            )
        case .turkish:
            return GameQuestion(
                id: 0,
                text: "Sorular yüklenemedi. Lütfen uygulamayı yeniden başlatın.",
                answers: [
                    AnswerOption(keywords: ["hata"],       displayWord: "Hata",       type: .trap),
                    AnswerOption(keywords: ["yükle"],      displayWord: "Yükle",      type: .normal),
                    AnswerOption(keywords: ["tekrar"],     displayWord: "Tekrar",     type: .target),
                    AnswerOption(keywords: ["başlat"],     displayWord: "Başlat",     type: .normal),
                    AnswerOption(keywords: ["uygulama"],  displayWord: "Uygulama",   type: .normal)
                ]
            )
        }
    }
}
