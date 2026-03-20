//
//  UserProfile.swift
//  third
//
//  Created by Claude on 19.03.2026.
//

import Foundation

struct UserProfile: Codable {
    var username: String

    private static let userDefaultsKey = "userProfile"

    static let defaultProfile = UserProfile(username: "Oyuncu")

    // MARK: - Persistence

    static func load() -> UserProfile {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return defaultProfile
        }
        return profile
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: UserProfile.userDefaultsKey)
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
