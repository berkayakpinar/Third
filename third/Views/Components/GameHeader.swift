//
//  GameHeader.swift
//  third
//
//  Created by Berkay Akpınar on 12.03.2026.
//

import SwiftUI

struct GameHeader: View {
    var body: some View {
        Text("Third.")
            .font(.custom("BebasNeue-Regular", size: 52))
            .foregroundStyle(Color.appForeground)
    }
}

struct GameStats: View {
    let totalScore: Int
    let pointsEarned: Int
    let questionNumber: Int
    let multiplier: Double

    @State private var displayedScore: Int
    @State private var showFloatingPoints = false
    @State private var floatingOffset: CGFloat = 0

    // Timer management for preventing memory leaks
    @State private var scoreAnimationTimer: Timer?

    init(totalScore: Int, pointsEarned: Int = 0, questionNumber: Int = 1, multiplier: Double = 1.0) {
        self.totalScore = totalScore
        self.pointsEarned = pointsEarned
        self.questionNumber = questionNumber
        self.multiplier = multiplier
        self._displayedScore = State(initialValue: totalScore)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Question Number Circle (Left)
            CircleStat(
                value: "\(questionNumber)",
                icon: nil,
                size: 70
            )

            // Score Card (Center)
            ZStack {
                RoundedRectangle(cornerRadius: 35, style: .continuous)
                    .fill(Color.cardLight)
                    .shadow(color: .black.opacity(0.65), radius: 15, x: 12, y: 10)
                    .shadow(color: .white.opacity(0.25), radius: 8, x: -3, y: -3)
                    .frame(width: 160, height: 70)

                Text("\(displayedScore)")
                    .font(.custom("Fredoka-Regular", size: 40))
                    .fontWeight(.medium)
                    .foregroundStyle(Color.appPrimaryText)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                if showFloatingPoints && pointsEarned > 0 {
                    Text("+\(pointsEarned)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.appTarget)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        .offset(y: floatingOffset)
                        .opacity(showFloatingPoints ? 1 : 0)
                }
            }

            // Multiplier Circle (Right)
            CircleStat(
                value: "x\(String(format: "%.1f", multiplier))",
                icon: nil,
                size: 70
            )
        }
        .onChange(of: totalScore) { oldValue, newValue in
            animateScoreChange(from: oldValue, to: newValue)
        }
        .onDisappear {
            // Clean up timer to prevent memory leaks
            scoreAnimationTimer?.invalidate()
            scoreAnimationTimer = nil
        }
    }

    private func animateScoreChange(from old: Int, to new: Int) {
        // Invalidate previous timer to prevent multiple animations
        scoreAnimationTimer?.invalidate()
        scoreAnimationTimer = nil

        let points = new - old

        if new < old {
            displayedScore = new
            return
        }

        let duration: Double = 0.6
        let steps = 30
        let stepValue = Double(points) / Double(steps)
        let stepDuration = duration / Double(steps)

        var currentStep = 0
        scoreAnimationTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [self] timer in
            currentStep += 1
            let increment = Int(stepValue * Double(currentStep))
            displayedScore = old + increment

            if currentStep >= steps {
                timer.invalidate()
                scoreAnimationTimer = nil
                displayedScore = new
            }
        }

        if points > 0 {
            showFloatingPoints = true
            floatingOffset = 0

            withAnimation(.easeOut(duration: 0.8)) {
                floatingOffset = -50
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showFloatingPoints = false
                }
            }
        }
    }
}

struct CircleStat: View {
    let value: String
    let icon: String?
    let size: CGFloat

    init(value: String, icon: String? = nil, size: CGFloat = 70) {
        self.value = value
        self.icon = icon
        self.size = size
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.cardLight)
                .shadow(color: .black.opacity(0.65), radius: 15, x: 12, y: 10)
                .shadow(color: .white.opacity(0.25), radius: 8, x: -3, y: -3)
                .frame(width: size, height: size)

            if let icon = icon {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                    Text(value)
                        .font(.custom("Fredoka-Regular", size: 24))
                        .fontWeight(.medium)
                }
                .foregroundStyle(Color.appPrimaryText)
            } else {
                Text(value)
                    .font(.custom("Fredoka-Regular", size: 24))
                    .fontWeight(.medium)
                    .foregroundStyle(Color.appPrimaryText)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
        }
    }
}

struct LivesDisplay: View {
    let lives: Int
    var trapTriggered: Bool = false

    @State private var isShaking = false
    @State private var flashingLifeIndex: Int?
    @State private var appearingLifeIndices: Set<Int> = []
    @State private var trapAnimationIndex: Int? = nil

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(lifeColor(for: index))
                    .frame(width: 16, height: 16)
                    .scaleEffect(lifeScale(for: index))
                    .opacity(lifeOpacity(for: index))
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: appearingLifeIndices)
                    .animation(.easeOut(duration: 0.3), value: trapAnimationIndex)
            }
        }
        .offset(x: isShaking ? CGFloat.random(in: -3...3) : 0)
        .animation(.none, value: isShaking)
        .onChange(of: lives) { oldValue, newValue in
            animateLivesChange(from: oldValue, to: newValue)
        }
        .onChange(of: trapTriggered) { _, newValue in
            if newValue {
                animateTrapEffect()
            }
        }
    }

    private func lifeScale(for index: Int) -> CGFloat {
        return appearingLifeIndices.contains(index) ? 1.5 : 1.0
    }

    private func lifeOpacity(for index: Int) -> CGFloat {
        if let trapIndex = trapAnimationIndex, index <= trapIndex {
            return 0.2
        }
        return 1.0
    }

    private func lifeColor(for index: Int) -> Color {
        if trapAnimationIndex != nil {
            return Color.appTrap
        }
        if flashingLifeIndex == index {
            return Color.appTrap
        } else if appearingLifeIndices.contains(index) {
            return Color.appTarget
        } else {
            return index < lives ? Color.appForeground : Color.appForeground.opacity(0.2)
        }
    }

    private func animateTrapEffect() {
        // All lives flash red sequentially then disappear
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                trapAnimationIndex = i
            }
        }
    }

    private func animateLivesChange(from old: Int, to new: Int) {
        if new < old {
            // Life lost - shake + red flash
            let lostLifeIndex = new

            // Shake animation
            isShaking = true
            withAnimation(.easeInOut(duration: 0.05).repeatCount(6)) {
                isShaking = false
            }

            // Red flash
            flashingLifeIndex = lostLifeIndex
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.2)) {
                    flashingLifeIndex = nil
                }
            }

        } else if new > old {
            // Lives regained - add all regained lives to set for animation
            for i in old..<new {
                appearingLifeIndices.insert(i)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.2)) {
                    appearingLifeIndices.removeAll()
                }
            }
        }
    }
}
