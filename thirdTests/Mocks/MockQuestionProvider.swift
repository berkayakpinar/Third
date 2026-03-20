//
//  MockQuestionProvider.swift
//  thirdTests
//

import Foundation
@testable import third

// MARK: - MockQuestionProvider

final class MockQuestionProvider: QuestionProviding {

    /// Cycle through this list on successive `getNextQuestion()` calls.
    var questionsToReturn: [GameQuestion] = []
    private var callCount = 0

    var loadCalled = false
    var loadForce: Bool?
    var resetCalled = false

    func getNextQuestion() -> GameQuestion {
        guard !questionsToReturn.isEmpty else {
            return MockQuestionProvider.makeQuestion()
        }
        let q = questionsToReturn[callCount % questionsToReturn.count]
        callCount += 1
        return q
    }

    func load(force: Bool) {
        loadCalled = true
        loadForce = force
    }

    func resetProgress() {
        resetCalled = true
    }
}

// MARK: - Factory helpers

extension MockQuestionProvider {

    /// Default 5-answer question with one of each type.
    static func makeQuestion(
        id: Int = 1,
        text: String = "Test sorusu?",
        targetKeyword: String = "hedef",
        trapKeyword: String = "tuzak",
        normalKeyword: String = "normal"
    ) -> GameQuestion {
        GameQuestion(
            id: id,
            text: text,
            answers: [
                AnswerOption(keywords: [trapKeyword],   displayWord: "Tuzak", type: .trap),
                AnswerOption(keywords: [normalKeyword], displayWord: "Normal", type: .normal),
                AnswerOption(keywords: [targetKeyword], displayWord: "Hedef",  type: .target),
                AnswerOption(keywords: ["diger1"],      displayWord: "Diğer1", type: .normal),
                AnswerOption(keywords: ["diger2"],      displayWord: "Diğer2", type: .normal)
            ]
        )
    }

    /// Question whose only answer is the target.
    static func makeSingleTargetQuestion(keyword: String = "hedef") -> GameQuestion {
        GameQuestion(
            id: 99,
            text: "Tek cevaplı soru",
            answers: [
                AnswerOption(keywords: ["tuzak"],  displayWord: "Tuzak",  type: .trap),
                AnswerOption(keywords: ["normal"], displayWord: "Normal", type: .normal),
                AnswerOption(keywords: [keyword],  displayWord: "Hedef",  type: .target),
                AnswerOption(keywords: ["d1"],     displayWord: "D1",     type: .normal),
                AnswerOption(keywords: ["d2"],     displayWord: "D2",     type: .normal)
            ]
        )
    }
}
