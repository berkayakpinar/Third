//
//  QuestionProviding.swift
//  third
//
//  Protocol that abstracts question loading and retrieval.
//  GameViewModel depends on this — not on the concrete GameData class.
//  This makes game logic fully testable with a MockQuestionProvider.
//

import Foundation

protocol QuestionProviding: AnyObject {
    /// Returns the next question, avoiding recently used ones.
    func getNextQuestion() -> GameQuestion

    /// Loads questions for the given language. Pass force: true to reload after a language change.
    func load(force: Bool)

    /// Resets the "used questions" tracker so all questions become available again.
    func resetProgress()
}

extension QuestionProviding {
    func load() { load(force: false) }
}
