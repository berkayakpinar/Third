//
//  GameOverView.swift
//  third
//
//  Created by Berkay Akpınar on 19.03.2026.
//

import SwiftUI

struct GameOverView: View {
    @Environment(UserSettings.self) private var userSettings
    let currentScore: Int
    let currentQuestion: Int
    let highScore: Int
    let furthestQuestion: Int
    let onPlayAgain: () -> Void
    let onExit: () -> Void

    @State private var showTitle = false
    @State private var showScore = false
    @State private var showHighScore = false
    @State private var showButtons = false
    @State private var displayedScore: Int = 0
    @State private var displayedHighScore: Int = 0

    var body: some View {
        ZStack {
            // Background dim overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            // Main White Card
            mainCardView
                .scaleEffect(showTitle ? 1 : 0.8)
                .opacity(showTitle ? 1 : 0)
        }
        // Entrance sequence — auto-cancelled when view disappears
        .task {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) { showTitle = true }

            try? await Task.sleep(for: .seconds(0.15))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { showScore = true }

            try? await Task.sleep(for: .seconds(0.20))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { showHighScore = true }

            try? await Task.sleep(for: .seconds(0.15))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { showButtons = true }
        }
        // Score count-up — auto-cancelled when view disappears
        .task {
            try? await Task.sleep(for: .seconds(0.15))
            await animateScore(to: currentScore)
        }
        // High score count-up — auto-cancelled when view disappears
        .task {
            try? await Task.sleep(for: .seconds(0.15))
            await animateHighScore(to: highScore)
        }
    }

    // MARK: - Main Card View

    private var mainCardView: some View {
        VStack(spacing: 20) {
            // Title
            titleView

            // Divider
            Rectangle()
                .fill(Color.appDark.opacity(0.1))
                .frame(height: 1)
                .padding(.horizontal, 20)

            // Stats Grid
            statsGrid

            // Divider
            Rectangle()
                .fill(Color.appDark.opacity(0.1))
                .frame(height: 1)
                .padding(.horizontal, 20)

            // Buttons
            buttonsView
        }
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.cardLight)
                .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 15)
                .shadow(color: .white.opacity(0.5), radius: 10, x: -5, y: -5)
        )
        .padding(.horizontal, 24)
        .frame(maxWidth: 400)
    }

    // MARK: - Title View

    private var titleView: some View {
        Text(AppStrings.gameOver(for: userSettings.selectedLanguage))
            .font(.custom("BebasNeue-Regular", size: 56))
            .foregroundStyle(Color.appBackgroundColor)
    }

    // MARK: - Stats Display

    private var statsGrid: some View {
        VStack(spacing: 24) {
            // Main Score - Large & Prominent
            VStack(spacing: 8) {
                Text(AppStrings.score(for: userSettings.selectedLanguage))
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(Color.appPrimaryText.opacity(0.5))
                    .tracking(2)

                Text("\(displayedScore)")
                    .font(.custom("Fredoka-Regular", size: 72))
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.appBackgroundColor, Color.appTertiaryColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.appBackgroundColor.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .scaleEffect(showScore ? 1 : 0.5)
            .opacity(showScore ? 1 : 0)

            // High Score with Icon
            HStack(spacing: 8) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.appSecondaryColor)

                Text("\(AppStrings.best(for: userSettings.selectedLanguage)) \(displayedHighScore)")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(Color.appPrimaryText.opacity(0.7))
            }
            .scaleEffect(showHighScore ? 1 : 0.8)
            .opacity(showHighScore ? 1 : 0)
        }
        .padding(.vertical, 16)
    }

    // MARK: - Buttons View

    private var buttonsView: some View {
        HStack(spacing: 12) {
            // Exit Button (secondary - smaller)
            Button(action: onExit) {
                Image(systemName: "house.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.appSecondaryText)
                    .frame(width: 52, height: 52)
                    .background(Color.appError)
                    .cornerRadius(12)
            }
            .scaleEffect(showButtons ? 1 : 0.8)
            .opacity(showButtons ? 1 : 0)

            // Play Again Button (primary - larger)
            Button(action: onPlayAgain) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 24, weight: .semibold))
                    Text(AppStrings.playAgain(for: userSettings.selectedLanguage))
                        .font(.system(size: 24, weight: .semibold))
                }
                .foregroundStyle(Color.appSecondaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.appBackgroundColor)
                .cornerRadius(12)
            }
            .scaleEffect(showButtons ? 1 : 0.8)
            .opacity(showButtons ? 1 : 0)
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Animations

    @MainActor
    private func animateScore(to target: Int) async {
        guard target > 0 else { displayedScore = 0; return }

        let steps = 30
        let stepValue = Double(target) / Double(steps)
        let stepDuration = Duration.milliseconds(800 / steps)

        for step in 1...steps {
            try? await Task.sleep(for: stepDuration)
            guard !Task.isCancelled else { return }
            displayedScore = step < steps ? Int(stepValue * Double(step)) : target
        }
    }

    @MainActor
    private func animateHighScore(to target: Int) async {
        guard target > 0 else { displayedHighScore = 0; return }

        let steps = 20
        let stepValue = Double(target) / Double(steps)
        let stepDuration = Duration.milliseconds(600 / steps)

        for step in 1...steps {
            try? await Task.sleep(for: stepDuration)
            guard !Task.isCancelled else { return }
            displayedHighScore = step < steps ? Int(stepValue * Double(step)) : target
        }
    }
}

#Preview("Normal") {
    ZStack {
        LinearGradient(
            colors: [
                Color.appPrimaryColor.opacity(0.35),
                Color.appBackgroundColor.opacity(0.65),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        GameOverView(
            currentScore: 1250,
            currentQuestion: 5,
            highScore: 2100,
            furthestQuestion: 12,
            onPlayAgain: {},
            onExit: {}
        )
    }
}

#Preview("New Record") {
    ZStack {
        LinearGradient(
            colors: [
                Color.appPrimaryColor.opacity(0.35),
                Color.appBackgroundColor.opacity(0.65),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        GameOverView(
            currentScore: 2500,
            currentQuestion: 8,
            highScore: 2100,
            furthestQuestion: 12,
            onPlayAgain: {},
            onExit: {}
        )
    }
}
