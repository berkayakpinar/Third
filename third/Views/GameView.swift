//
//  GameView.swift
//  third
//
//  Created by Berkay Akpınar on 12.03.2026.
//

import SwiftUI

enum GameViewStatus {
    case playing
    case questionWon
    case lost
}

// MARK: - Scoring Configuration
private struct ScoringConfig {
    /// Base scores based on lives used: [0 lives, 1 life, 2 lives, 3+ lives]
    static let baseScores = [300, 200, 100, 0]
    /// Multiplier increase per question (10% per question)
    static let multiplierPerQuestion: Double = 0.1
}

struct GameView: View {
    @Binding var gameState: GameState
    @Binding var currentQuestionIndex: Int
    let isNewGame: Bool
    let onDismiss: () -> Void
    let onRestartGame: () -> Void

    // Dependency injection for testability
    var statsManager: GameStatsManager = .shared

    @State private var viewStatus: GameViewStatus = .playing
    @State private var inputText = ""
    @State private var question = GameData.getNextQuestion()
    @State private var shakeOffset: CGFloat = 0
    @FocusState private var isInputFocused: Bool

    // Animation state variables
    @State private var boxVisibleProgress: Double = 1.0
    @State private var trapTriggered: Bool = false
    @State private var targetRevealed: Bool = false
    @State private var lastQuestionScore: Int = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.appBackground,              // Üst - tam renk
                    Color.appBackground.opacity(0.75),// Alt - hafif koyu
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // PLAYING STATE: Full game UI
            ZStack {
                VStack(spacing: 0) {
                    // TOP AREA: "Third." title centered
                    HStack {
                        Spacer()
                        GameHeader()
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)


                    Spacer()
                        .frame(height: 8)

                    // GAME INFO AREA: Score
                    GameStats(
                        totalScore: gameState.totalScore,
                        pointsEarned: lastQuestionScore,
                        questionNumber: gameState.currentQuestionIndex,
                        multiplier: 1.0 + (Double(gameState.currentQuestionIndex - 1) * 0.1)
                    )
                    .padding(.bottom, 16)

                    // Lives display (between score and question)
                    LivesDisplay(lives: gameState.lives, trapTriggered: trapTriggered)
                        .padding(.bottom, 16)

                    // QUESTION AREA
                    Text(question.text)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color.appPrimaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.cardLight)
                                .shadow(color: .black.opacity(0.65), radius: 15, x: 12, y: 10)
                                .shadow(color: .white.opacity(0.25), radius: 8, x: -3, y: -3)
                        )
                        .padding(.horizontal, 24)

                    // ANSWERS AREA - centered with equal spacing
                    AnswerBoxesRow(
                        answers: question.answers,
                        visibleProgress: boxVisibleProgress,
                        trapTriggered: trapTriggered,
                        targetRevealed: targetRevealed,
                        isQuestionWon: viewStatus == .questionWon
                    )
                    .padding(.horizontal, 24)
                    .padding(.vertical, 40)

                    // INPUT AREA - conditionally show input or button
                    if viewStatus == .questionWon {
                        Button(action: nextQuestion) {
                            Text("Sıradaki Soru")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(Color.appSecondaryText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color.appBackgroundColor)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 16)
                    } else {
                        GameInput(inputText: $inputText, onSubmit: submitAnswer)
                            .disabled(viewStatus != .playing)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .offset(x: shakeOffset)

                // Back button (top left)
                VStack {
                    HStack {
                        Button {
                            onDismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundStyle(Color.appForeground)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.leading)
                    .padding(.top, 8)
                    Spacer()
                }
            }

            // Game over overlay
            gameOverOverlay
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onTapGesture {
            isInputFocused = false
        }
    }

    @ViewBuilder
    private var gameOverOverlay: some View {
        if viewStatus == .lost {
            GameOverView(
                currentScore: gameState.totalScore,
                currentQuestion: currentQuestionIndex - 1,
                highScore: statsManager.highScore,
                furthestQuestion: statsManager.furthestQuestion,
                onPlayAgain: restartGame,
                onExit: onDismiss
            )
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }

    private func submitAnswer() {
        let normalizedInput = inputText.lowercased().trimmingCharacters(in: .whitespaces)
        guard !normalizedInput.isEmpty else { return }

        // Check each answer option
        for (index, answer) in question.answers.enumerated() {
            if answer.keywords.contains(normalizedInput) {
                handleCorrectAnswer(at: index)
                inputText = ""
                return
            }
        }

        // Word not in list - lose 1 life
        handleWrongAnswer()
    }

    private func handleCorrectAnswer(at index: Int) {
        let answer = question.answers[index]

        switch answer.type {
        case .trap:
            // Instant fail - game over after delay
            trapTriggered = true
            gameState.lives = 0
            triggerHaptic(.heavy)
            triggerShakeAnimation()
            question.answers[index].isRevealed = true

            // Save game stats before showing game over
            statsManager.saveGameResult(score: gameState.totalScore, questionIndex: currentQuestionIndex, currentStreak: 0)

            // Show game over overlay after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                viewStatus = .lost
            }

            // Reset trigger after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                trapTriggered = false
            }

        case .target:
            // Correct answer - calculate score and move to next question
            targetRevealed = true
            lastQuestionScore = calculateScore()
            gameState.totalScore += lastQuestionScore
            viewStatus = .questionWon
            triggerHaptic(.heavy)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                triggerHaptic(.heavy)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                triggerHaptic(.heavy)
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                revealAllAnswers()
            }

        case .normal:
            // Reveal this answer, lose 1 life
            question.answers[index].isRevealed = true
            gameState.lives -= 1
            gameState.livesUsedThisQuestion += 1
            triggerHaptic(.medium)

            if gameState.lives == 0 {
                // Save game stats
                statsManager.saveGameResult(score: gameState.totalScore, questionIndex: currentQuestionIndex, currentStreak: 0)
                viewStatus = .lost
            }
        }
    }

    private func handleWrongAnswer() {
        gameState.lives -= 1
        gameState.livesUsedThisQuestion += 1
        inputText = ""
        if gameState.lives == 0 {
            // Save game stats
            statsManager.saveGameResult(score: gameState.totalScore, questionIndex: currentQuestionIndex, currentStreak: 0)
            viewStatus = .lost
        }
    }

    private func revealAllAnswers() {
        for index in question.answers.indices {
            question.answers[index].isRevealed = true
        }
    }

    private func triggerShakeAnimation() {
        withAnimation(.easeInOut(duration: 0.05).repeatCount(5)) {
            shakeOffset = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            shakeOffset = 0
        }
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    private func calculateScore() -> Int {
        let livesUsed = min(gameState.livesUsedThisQuestion, ScoringConfig.baseScores.count - 1)
        let baseScore = ScoringConfig.baseScores[livesUsed]
        let multiplier = 1.0 + (Double(gameState.currentQuestionIndex - 1) * ScoringConfig.multiplierPerQuestion)
        return Int(Double(baseScore) * multiplier)
    }

    private func nextQuestion() {
        gameState.currentQuestionIndex += 1
        gameState.lives = 3
        gameState.livesUsedThisQuestion = 0
        question = GameData.getNextQuestion()
        lastQuestionScore = 0
        viewStatus = .playing

        // Reset animation states
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            boxVisibleProgress = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                boxVisibleProgress = 1.0
            }
        }
    }

    private func restartGame() {
        onRestartGame()
        gameState = GameState()
        currentQuestionIndex = 1
        question = GameData.getNextQuestion()
        lastQuestionScore = 0
        viewStatus = .playing

        // Reset animation states
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            boxVisibleProgress = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                boxVisibleProgress = 1.0
            }
        }
    }
}

extension Animation {
    static var cascade: Animation {
        .easeOut(duration: 0.4)
    }
}

#Preview {
    GameView(
        gameState: .constant(GameState()),
        currentQuestionIndex: .constant(1),
        isNewGame: true,
        onDismiss: { print("Dismiss") },
        onRestartGame: { print("Restart Game") }
    )
}
