//
//  AnswerBoxesRow.swift
//  third
//
//  Created by Berkay Akpınar on 12.03.2026.
//

import SwiftUI

struct AnswerBoxesRow: View {
    let answers: [AnswerOption]
    var visibleProgress: Double = 1.0  // 0.0 to 1.0 for staggered animation
    var trapTriggered: Bool = false
    var targetRevealed: Bool = false
    var isQuestionWon: Bool = false

    var body: some View {
        VStack(spacing: 12) {
            if answers.count > 0 { makeAnswerBox(index: 0, answer: answers[0]) }
            if answers.count > 1 { makeAnswerBox(index: 1, answer: answers[1]) }
            if answers.count > 2 { makeAnswerBox(index: 2, answer: answers[2]) }
            if answers.count > 3 { makeAnswerBox(index: 3, answer: answers[3]) }
            if answers.count > 4 { makeAnswerBox(index: 4, answer: answers[4]) }
        }
    }

    @ViewBuilder
    private func makeAnswerBox(index: Int, answer: AnswerOption) -> some View {
        let boxThreshold = Double(index) / 5.0  // 0.0, 0.2, 0.4, 0.6, 0.8
        let isVisible = visibleProgress > boxThreshold

        AnswerBox(
            answer: answer,
            rank: index + 1,
            isTrapTriggered: trapTriggered,
            isTargetRevealed: targetRevealed,
            isQuestionWon: isQuestionWon
        )
            .scaleEffect(isVisible ? 1 : 0.5)
            .opacity(isVisible ? 1 : 0)
            .rotation3DEffect(
                Angle(degrees: isVisible ? 0 : 45),
                axis: (x: 1, y: 0, z: 0)
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isVisible)
    }
}
