//
//  GameModels.swift
//  third
//
//  Created by Berkay Akpınar on 12.03.2026.
//

import SwiftUI

struct AnswerOption: Identifiable, Codable {
    /// Stable, content-derived identifier — consistent across encode/decode cycles.
    let id: String
    let keywords: [String]          // Case-insensitive variations
    let displayWord: String          // The word to reveal
    let type: AnswerType
    var isRevealed: Bool = false     // UI state

    enum CodingKeys: String, CodingKey {
        case keywords, displayWord, type, isRevealed
    }

    init(keywords: [String], displayWord: String, type: AnswerType, isRevealed: Bool = false) {
        self.id = displayWord
        self.keywords = keywords
        self.displayWord = displayWord
        self.type = type
        self.isRevealed = isRevealed
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.keywords = try container.decode([String].self, forKey: .keywords)
        self.displayWord = try container.decode(String.self, forKey: .displayWord)
        self.type = try container.decode(AnswerType.self, forKey: .type)
        self.isRevealed = try container.decodeIfPresent(Bool.self, forKey: .isRevealed) ?? false
        self.id = displayWord
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(keywords, forKey: .keywords)
        try container.encode(displayWord, forKey: .displayWord)
        try container.encode(type, forKey: .type)
        try container.encode(isRevealed, forKey: .isRevealed)
    }
}

enum AnswerType: String, Codable {
    case trap   = "trap"    // Red border - Instant fail
    case target = "target"  // Green border - Win condition
    case normal = "normal"  // Gray border - Lose 1 life
}

struct GameQuestion: Codable {
    let id: Int
    let text: String
    var answers: [AnswerOption]
}

struct GameState: Codable {
    var lives: Int = 3
    var currentQuestionIndex: Int = 1
    var totalScore: Int = 0
    var livesUsedThisQuestion: Int = 0
}

// MARK: - App Theme
extension Color {
    /// #441E86 - BackgroundColor - Deep backgrounds
    static let appBackgroundColor = Color(hex: "441E86")

    /// #ffea80 - PrimaryColor - Primary brand color
    static let appPrimaryColor = Color(hex: "ffea80")

    /// #FFD166 - SecondaryColor - Highlights, achievements, premium elements
    static let appSecondaryColor = Color(hex: "FFD166")

    /// #E13B83 - TertiaryColor - Accents, secondary actions
    static let appTertiaryColor = Color(hex: "E13B83")

    /// #67904C - Success - Correct answers, positive feedback
    static let appSuccess = Color(hex: "67904C")

    /// #C34949 - Error - Wrong answers, traps, negative feedback
    static let appError = Color(hex: "C34949")

    /// #FFFFFF - Light - Text, foregrounds
    static let appLight = Color(hex: "FFFFFF")

    /// #212529 - Dark - Cards, inputs
    static let appDark = Color(hex: "212529")

    /// #22053c - PrimaryText - Dark text
    static let appPrimaryText = Color(hex: "22053c")

    /// #FFFFFF - SecondaryText - Light text
    static let appSecondaryText = Color(hex: "FFFFFF")

    /// #F3EEFB - CardLight - Card backgrounds
    static let cardLight = Color(hex: "F3EEFB")

    /// #212529 - CardDark - Card shadows, gradients
    static let cardDark = Color(hex: "212529")

    // MARK: - Semantic Aliases
    static let appBackground = appBackgroundColor
    static let appForeground = appLight
    static let appTarget = appSuccess
    static let appTrap = appError
    static let appCard = appDark
}

extension Color {
    /// Initialize a Color from a hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        // Parse hex based on format
        let components = HexColorParser.parse(hex: hex, intValue: int)

        self.init(
            .sRGB,
            red: Double(components.r) / 255,
            green: Double(components.g) / 255,
            blue: Double(components.b) / 255,
            opacity: Double(components.a) / 255
        )
    }
}

// MARK: - Hex Color Parser
private struct HexColorParser {
    /// Parsed RGBA components
    struct Components {
        let a, r, g, b: UInt64
    }

    /// Parse hex string and return RGBA components
    static func parse(hex: String, intValue: UInt64) -> Components {
        switch hex.count {
        case 3: // RGB (12-bit) - each digit is repeated (e.g., "F00" -> "FF0000")
            return Components(
                a: 255,
                r: (intValue >> 8 & 0xF) * 17,
                g: (intValue >> 4 & 0xF) * 17,
                b: (intValue & 0xF) * 17
            )
        case 6: // RGB (24-bit)
            return Components(
                a: 255,
                r: intValue >> 16 & 0xFF,
                g: intValue >> 8 & 0xFF,
                b: intValue & 0xFF
            )
        case 8: // ARGB (32-bit)
            return Components(
                a: intValue >> 24 & 0xFF,
                r: intValue >> 16 & 0xFF,
                g: intValue >> 8 & 0xFF,
                b: intValue & 0xFF
            )
        default: // Invalid format - return transparent black
            return Components(a: 255, r: 0, g: 0, b: 0)
        }
    }
}
