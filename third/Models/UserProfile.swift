//
//  UserProfile.swift
//  third
//
//  Created by Claude on 19.03.2026.
//

import Foundation
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "third", category: "UserProfile")

struct UserProfile: Codable {
    var username: String

    static let defaultProfile = UserProfile(username: "Oyuncu")

    // MARK: - Persistence

    static func load() -> UserProfile {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKey.userProfile.rawValue),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return defaultProfile
        }
        return profile
    }

    @discardableResult
    func save() -> Bool {
        do {
            let data = try JSONEncoder().encode(self)
            UserDefaults.standard.set(data, forKey: UserDefaultsKey.userProfile.rawValue)
            return true
        } catch {
            logger.error("Failed to save UserProfile: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Validation

    var isValidUsername: Bool {
        !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && username.count <= 20
    }

    var trimmedUsername: String {
        username.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
