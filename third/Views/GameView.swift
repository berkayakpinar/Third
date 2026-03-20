//
//  GameView.swift
//  third
//
//  Thin view layer — UI rendering and animations only.
//  All game logic lives in GameViewModel.
//

import SwiftUI

struct GameView: View {
    @Environment(UserSettings.self) private var userSettings
    let viewModel: GameViewModel
    let onDismiss: () -> Void

    // MARK: - Animation-only state (purely visual, not persisted)
    @State private var shakeOffset: CGFloat = 0
    @State private var boxVisibleProgress: Double = 1.0
    @State private var trapTriggered: Bool = false
    @State private var targetRevealed: Bool = false
    @FocusState private var isInputFocused: Bool

    private let lightHaptic  = UIImpactFeedbackGenerator(style: .light)
    private let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)
    private let heavyHaptic  = UIImpactFeedbackGenerator(style: .heavy)

    // MARK: - Body

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.appBackground, Color.appBackground.opacity(0.75)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            gameContent
            gameOverOverlay
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onTapGesture { isInputFocused = false }
        .onDisappear { viewModel.cancelPendingTasks() }
        .onChange(of: viewModel.animationSignal) { _, signal in
            handleAnimationEvent(signal.event)
        }
        // Animate GameOverView in/out automatically when viewStatus changes
        .animation(.easeInOut(duration: 0.3), value: viewModel.viewStatus == .lost)
    }

    // MARK: - Game Content

    private var gameContent: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    GameHeader()
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Spacer().frame(height: 8)

                GameStats(
                    totalScore: viewModel.gameState.totalScore,
                    pointsEarned: viewModel.lastQuestionScore,
                    questionNumber: viewModel.gameState.currentQuestionIndex,
                    multiplier: 1.0 + (Double(viewModel.gameState.currentQuestionIndex - 1) * ScoringConfig.multiplierPerQuestion)
                )
                .padding(.bottom, 16)

                LivesDisplay(lives: viewModel.gameState.lives, trapTriggered: trapTriggered)
                    .padding(.bottom, 16)

                Text(viewModel.question.text)
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

                AnswerBoxesRow(
                    answers: viewModel.question.answers,
                    visibleProgress: boxVisibleProgress,
                    trapTriggered: trapTriggered,
                    targetRevealed: targetRevealed,
                    isQuestionWon: viewModel.viewStatus == .questionWon
                )
                .padding(.horizontal, 24)
                .padding(.vertical, 40)

                inputArea
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .offset(x: shakeOffset)

            backButton
        }
    }

    @ViewBuilder
    private var inputArea: some View {
        if viewModel.viewStatus == .questionWon {
            Button(action: viewModel.nextQuestion) {
                Text(AppStrings.nextQuestion(for: userSettings.selectedLanguage))
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.appSecondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.appBackgroundColor)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 16)
        } else {
            @Bindable var vm = viewModel
            GameInput(inputText: $vm.inputText, onSubmit: viewModel.submitAnswer)
                .disabled(viewModel.viewStatus != .playing)
        }
    }

    private var backButton: some View {
        VStack {
            HStack {
                Button(action: onDismiss) {
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

    @ViewBuilder
    private var gameOverOverlay: some View {
        if viewModel.viewStatus == .lost {
            GameOverView(
                currentScore: viewModel.gameState.totalScore,
                currentQuestion: viewModel.gameState.currentQuestionIndex - 1,
                highScore: viewModel.highScore,
                furthestQuestion: viewModel.furthestQuestion,
                onPlayAgain: viewModel.restartGame,
                onExit: onDismiss
            )
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }

    // MARK: - Animation Handling

    private func handleAnimationEvent(_ event: GameAnimationEvent) {
        switch event {
        case .trap:
            trapTriggered = true
            triggerHaptic(.heavy)
            triggerShakeAnimation()
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.5))
                trapTriggered = false
            }

        case .target:
            targetRevealed = true
            triggerHaptic(.heavy)
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.1))
                triggerHaptic(.heavy)
                try? await Task.sleep(for: .seconds(0.1))
                triggerHaptic(.heavy)
            }

        case .wrongAnswer:
            triggerHaptic(.medium)
            triggerShakeAnimation()

        case .nextQuestion:
            targetRevealed = false
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                boxVisibleProgress = 0
            }
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.3))
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    boxVisibleProgress = 1.0
                }
            }
        }
    }

    private func triggerShakeAnimation() {
        withAnimation(.easeInOut(duration: 0.05).repeatCount(5)) {
            shakeOffset = 10
        }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.25))
            shakeOffset = 0
        }
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .light:  lightHaptic.prepare();  lightHaptic.impactOccurred()
        case .medium: mediumHaptic.prepare(); mediumHaptic.impactOccurred()
        case .heavy:  heavyHaptic.prepare();  heavyHaptic.impactOccurred()
        default:      UIImpactFeedbackGenerator(style: style).impactOccurred()
        }
    }
}

// MARK: - Animation Extension

extension Animation {
    static var cascade: Animation { .easeOut(duration: 0.4) }
}
