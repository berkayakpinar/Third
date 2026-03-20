//
//  AnswerBox.swift
//  third
//
//  Created by Berkay Akpınar on 12.03.2026.
//

import SwiftUI

struct AnswerBox: View {
    let answer: AnswerOption
    let rank: Int  // 1-5 popularity ranking
    let isTrapTriggered: Bool
    let isTargetRevealed: Bool
    let isQuestionWon: Bool

    @State private var isAnimating = false

    // MARK: - Answer Style Configuration
    private var style: AnswerStyle {
        AnswerStyle(type: answer.type, isRevealed: answer.isRevealed)
    }

    init(
        answer: AnswerOption,
        rank: Int,
        isTrapTriggered: Bool = false,
        isTargetRevealed: Bool = false,
        isQuestionWon: Bool = false
    ) {
        self.answer = answer
        self.rank = rank
        self.isTrapTriggered = isTrapTriggered
        self.isTargetRevealed = isTargetRevealed
        self.isQuestionWon = isQuestionWon
    }

    var body: some View {
        SquircleBox(
            tintColor: tintColor,
            borderColor: borderColor,
            solidFill: solidFillColor,
            showMaterial: false
        ) {
            ZStack {
                if !answer.isRevealed {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(0.8)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                Text(answer.displayWord)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(textColor)
                    .blur(radius: answer.isRevealed ? 0 : 8)
                    .padding(.horizontal, 16)

                HStack {
                    Text("\(rank)")
                        .font(.custom("Fredoka-Regular", size: 24))
                        .fontWeight(.bold)
                        .foregroundStyle(numberColor)
                        .padding(.leading, 20)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 50)
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: answer.isRevealed)
        .popSettle(isActive: isAnimating)
        .onChange(of: answer.isRevealed) { _, newValue in
            if newValue {
                isAnimating = true
            }
        }
        .shake(trigger: isTrapTriggered && answer.type == .trap)
    }

    private var borderColor: Color {
        style.borderColor
    }

    private var textColor: Color {
        style.textColor
    }

    private var numberColor: Color {
        style.numberColor
    }

    private var tintColor: Color {
        style.tintColor
    }

    private var solidFillColor: Color? {
        style.solidFillColor
    }
}

// MARK: - Answer Style Configuration
private enum AnswerStyle {
    case trap(isRevealed: Bool)
    case target(isRevealed: Bool)
    case normal

    init(type: AnswerType, isRevealed: Bool) {
        switch type {
        case .trap:
            self = .trap(isRevealed: isRevealed)
        case .target:
            self = .target(isRevealed: isRevealed)
        case .normal:
            self = .normal
        }
    }

    var borderColor: Color {
        switch self {
        case .trap: return .appTrap
        case .target: return .appTarget
        case .normal: return .cardLight
        }
    }

    var textColor: Color {
        switch self {
        case .trap(let isRevealed), .target(let isRevealed):
            return isRevealed ? .appSecondaryText : .appPrimaryText
        case .normal:
            return .appPrimaryText
        }
    }

    var numberColor: Color {
        switch self {
        case .trap(let isRevealed):
            return isRevealed ? .appSecondaryText : .appTrap
        case .target(let isRevealed):
            return isRevealed ? .appSecondaryText : .appTarget
        case .normal:
            return .appPrimaryText
        }
    }

    var tintColor: Color {
        switch self {
        case .trap: return .appTrap.opacity(0.15)
        case .target: return .appTarget.opacity(0.15)
        case .normal: return .appBackground.opacity(0)
        }
    }

    var solidFillColor: Color? {
        switch self {
        case .trap(let isRevealed):
            return isRevealed ? .appTrap : nil
        case .target(let isRevealed):
            return isRevealed ? .appTarget : nil
        case .normal:
            return nil
        }
    }
}
