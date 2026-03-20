//
//  QuestionLoader.swift
//  third
//
//  Created by Berkay Akpınar on 20.03.2026.
//

import Foundation
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "third", category: "QuestionLoader")

enum QuestionError: Error, LocalizedError {
    case fileNotFound
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Soru dosyası bulunamadı"
        case .decodingFailed(let error):
            return "Soru dosyası okunamadı: \(error.localizedDescription)"
        }
    }
}

class QuestionLoader {
    static func loadQuestions(for language: AppLanguage) throws -> [GameQuestion] {
        let fileName: String
        switch language {
        case .turkish:
            fileName = "turkish"
        case .english:
            fileName = "english"
        }

        // Önce subdirectory ile dene, sonra kök dizinde dene
        var url = Bundle.main.url(forResource: "Questions/\(fileName)", withExtension: "json")

        if url == nil {
            url = Bundle.main.url(forResource: fileName, withExtension: "json")
        }

        guard let validUrl = url else {
            logger.error("\(fileName).json not found in bundle")
            throw QuestionError.fileNotFound
        }

        let data = try Data(contentsOf: validUrl)
        let decoder = JSONDecoder()

        do {
            let container = try decoder.decode(QuestionContainerDTO.self, from: data)
            // DTO'ları gerçek model objelerine dönüştür
            return container.questions.map { dto in
                let answers = dto.answers.enumerated().map { index, answerDTO in
                    let answerType = answerDTO.type.flatMap(AnswerType.init(rawValue:)) ?? {
                        // Geriye dönük uyumluluk: JSON'da type yoksa index'e göre belirle
                        switch index {
                        case 0: return AnswerType.trap
                        case 2: return AnswerType.target
                        default: return AnswerType.normal
                        }
                    }()
                    return AnswerOption(keywords: answerDTO.keywords, displayWord: answerDTO.displayWord, type: answerType)
                }
                return GameQuestion(id: dto.id, text: dto.text, answers: answers)
            }
        } catch {
            throw QuestionError.decodingFailed(error)
        }
    }
}

// MARK: - DTO (Data Transfer Objects) for JSON decoding

struct QuestionContainerDTO: Codable {
    let questions: [QuestionDTO]
}

struct QuestionDTO: Codable {
    let id: Int
    let text: String
    let answers: [AnswerOptionDTO]
}

struct AnswerOptionDTO: Codable {
    let keywords: [String]
    let displayWord: String
    /// Explicit answer type. If absent, type is derived from position in array (legacy fallback).
    let type: String?
}
