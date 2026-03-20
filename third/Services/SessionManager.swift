//
//  SessionManager.swift
//  third
//
//  Created by Berkay Akpınar on 18.03.2026.
//

import Foundation

// MARK: - Session Configuration
private enum SessionConfig {
    static let maxSessionAgeInDays: Int = 30
}

// MARK: - Session Errors
enum SessionError: Error, LocalizedError {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case expiredSession
    case noActiveSession

    var errorDescription: String? {
        switch self {
        case .encodingFailed(let error):
            return "Oyun kaydedilemedi: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Oyun yüklenemedi: \(error.localizedDescription)"
        case .expiredSession:
            return "Oyun oturumu süresi doldu"
        case .noActiveSession:
            return "Aktif oyun oturumu yok"
        }
    }
}

@Observable
class SessionManager {
    static let shared = SessionManager()

    private let userDefaults = UserDefaults.standard
    private let sessionKey = "currentGameSession"

    var currentSession: GameSession? {
        didSet {
            save()
        }
    }

    var hasActiveSession: Bool {
        guard let session = currentSession else { return false }
        return session.isActive
    }

    private init() {
        load()
    }

    func startNewGame() -> GameSession {
        let newSession = GameSession(
            gameState: GameState(),
            currentQuestionIndex: 1,
            questionStates: [],
            timestamp: Date(),
            isNewGame: true
        )
        currentSession = newSession
        return newSession
    }

    func clearSession() {
        currentSession = nil
        userDefaults.removeObject(forKey: sessionKey)
    }

    private func save() {
        guard let session = currentSession else { return }

        do {
            let data = try JSONEncoder().encode(session)
            userDefaults.set(data, forKey: sessionKey)
        } catch {
            // Log error for debugging
            #if DEBUG
            print("⚠️ SessionManager: Failed to encode session - \(error)")
            #endif
            // Could send to crash reporting service here (e.g., Firebase Crashlytics)
            // Crashlytics.crashlytics().record(error: SessionError.encodingFailed(error))
        }
    }

    private func load() {
        guard let data = userDefaults.data(forKey: sessionKey) else {
            currentSession = nil
            return
        }

        do {
            let session = try JSONDecoder().decode(GameSession.self, from: data)
            // Session'ın çok eski olup olmadığını kontrol edelim
            let daysSinceLastPlay = Calendar.current.dateComponents([.day], from: session.timestamp, to: Date()).day ?? 0
            if daysSinceLastPlay > SessionConfig.maxSessionAgeInDays || !session.isActive {
                currentSession = nil
                userDefaults.removeObject(forKey: sessionKey)
            } else {
                currentSession = session
            }
        } catch {
            // Log error for debugging
            #if DEBUG
            print("⚠️ SessionManager: Failed to decode session - \(error)")
            #endif
            // Clear corrupted data
            currentSession = nil
            userDefaults.removeObject(forKey: sessionKey)
            // Could send to crash reporting service here
        }
    }
}
