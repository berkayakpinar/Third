//
//  GameViewModel.swift
//  third
//

import SwiftUI

// MARK: - GameViewModel
// Types (GameViewStatus, GameAnimationEvent, AnimationSignal, ScoringConfig)
// are defined in GameViewModelTypes.swift (Foundation-only, no @MainActor isolation)

@Observable
class GameViewModel {

    // MARK: - Game State (read-only from View)
    private(set) var gameState: GameState
    private(set) var viewStatus: GameViewStatus = .playing
    private(set) var question: GameQuestion
    private(set) var lastQuestionScore: Int = 0
    private(set) var animationSignal: AnimationSignal = AnimationSignal(id: 0, event: .nextQuestion)

    // MARK: - Input (two-way binding from View)
    var inputText: String = ""

    // MARK: - Cancellable task
    private(set) var gameOverTask: Task<Void, Never>?
    private var signalCounter = 0

    // MARK: - Stats (proxied from statsManager for View access)
    var highScore: Int { statsManager.highScore }
    var furthestQuestion: Int { statsManager.furthestQuestion }

    // MARK: - Dependencies
    let isNewGame: Bool
    private let questionProvider: QuestionProviding
    private let statsManager: StatsManaging
    private let onGameStateChanged: (GameState) -> Void
    private let onRestartRequested: () -> Void

    // MARK: - Init

    init(
        initialGameState: GameState,
        isNewGame: Bool,
        questionProvider: QuestionProviding = GameData.shared,
        statsManager: StatsManaging = GameStatsManager.shared,
        onGameStateChanged: @escaping (GameState) -> Void,
        onRestartRequested: @escaping () -> Void
    ) {
        self.gameState = initialGameState
        self.isNewGame = isNewGame
        self.questionProvider = questionProvider
        self.statsManager = statsManager
        self.onGameStateChanged = onGameStateChanged
        self.onRestartRequested = onRestartRequested
        self.question = questionProvider.getNextQuestion()
    }

    // MARK: - Public API

    func submitAnswer() {
        let normalized = inputText.lowercased().trimmingCharacters(in: .whitespaces)
        guard !normalized.isEmpty else { return }

        for (index, answer) in question.answers.enumerated() {
            if answer.keywords.contains(normalized) {
                handleCorrectAnswer(at: index)
                inputText = ""
                return
            }
        }
        handleWrongAnswer()
    }

    func nextQuestion() {
        gameState.currentQuestionIndex += 1
        gameState.lives = 3
        gameState.livesUsedThisQuestion = 0
        question = questionProvider.getNextQuestion()
        lastQuestionScore = 0
        viewStatus = .playing
        signal(.nextQuestion)
        syncState()
    }

    func restartGame() {
        gameOverTask?.cancel()
        onRestartRequested()
        gameState = GameState()
        question = questionProvider.getNextQuestion()
        lastQuestionScore = 0
        viewStatus = .playing
        signal(.nextQuestion)
        syncState()
    }

    func cancelPendingTasks() {
        gameOverTask?.cancel()
    }

    // MARK: - Score Calculation

    func calculateScore() -> Int {
        let livesUsed = min(gameState.livesUsedThisQuestion, ScoringConfig.baseScores.count - 1)
        let baseScore = ScoringConfig.baseScores[livesUsed]
        let multiplier = 1.0 + (Double(gameState.currentQuestionIndex - 1) * ScoringConfig.multiplierPerQuestion)
        return Int(Double(baseScore) * multiplier)
    }

    // MARK: - Private

    private func handleCorrectAnswer(at index: Int) {
        switch question.answers[index].type {
        case .trap:
            question.answers[index].isRevealed = true
            gameState.lives = 0
            statsManager.saveGameResult(
                score: gameState.totalScore,
                questionIndex: gameState.currentQuestionIndex
            )
            signal(.trap)
            syncState()

            gameOverTask?.cancel()
            gameOverTask = Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(2.0))
                guard !Task.isCancelled else { return }
                self?.viewStatus = .lost
            }

        case .target:
            lastQuestionScore = calculateScore()
            gameState.totalScore += lastQuestionScore
            viewStatus = .questionWon
            revealAllAnswers()
            signal(.target)
            syncState()

        case .normal:
            question.answers[index].isRevealed = true
            gameState.lives -= 1
            gameState.livesUsedThisQuestion += 1
            signal(.wrongAnswer)

            if gameState.lives == 0 {
                statsManager.saveGameResult(
                    score: gameState.totalScore,
                    questionIndex: gameState.currentQuestionIndex
                )
                viewStatus = .lost
            }
            syncState()
        }
    }

    private func handleWrongAnswer() {
        gameState.lives -= 1
        gameState.livesUsedThisQuestion += 1
        inputText = ""
        signal(.wrongAnswer)

        if gameState.lives == 0 {
            statsManager.saveGameResult(
                score: gameState.totalScore,
                questionIndex: gameState.currentQuestionIndex
            )
            viewStatus = .lost
        }
        syncState()
    }

    private func revealAllAnswers() {
        for index in question.answers.indices {
            question.answers[index].isRevealed = true
        }
    }

    private func signal(_ event: GameAnimationEvent) {
        signalCounter += 1
        animationSignal = AnimationSignal(id: signalCounter, event: event)
    }

    private func syncState() {
        onGameStateChanged(gameState)
    }
}
