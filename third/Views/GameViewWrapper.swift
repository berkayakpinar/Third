//
//  GameViewWrapper.swift
//  third
//
//  Created by Berkay Akpınar on 18.03.2026.
//

import SwiftUI

struct GameViewWrapper: View {
    @Environment(SessionManager.self) private var sessionManager
    @Environment(\.dismiss) private var dismiss

    // Optional custom dismiss handler (for overlay presentation)
    var customOnDismiss: (() -> Void)? = nil

    var body: some View {
        GameView(
            gameState: Binding(
                get: { sessionManager.currentSession?.gameState ?? GameState() },
                set: { newValue in
                    if var session = sessionManager.currentSession {
                        session.gameState = newValue
                        sessionManager.currentSession = session
                    }
                }
            ),
            currentQuestionIndex: Binding(
                get: { sessionManager.currentSession?.currentQuestionIndex ?? 1 },
                set: { newValue in
                    if var session = sessionManager.currentSession {
                        session.currentQuestionIndex = newValue
                        sessionManager.currentSession = session
                    }
                }
            ),
            isNewGame: sessionManager.currentSession?.isNewGame ?? true,
            onDismiss: {
                // Don't clear session on back button - user may want to continue
                // Session only clears when game is over (lives == 0)
                if let customOnDismiss = customOnDismiss {
                    customOnDismiss()
                } else {
                    dismiss()
                }
            },
            onRestartGame: {
                sessionManager.startNewGame()
            }
        )
    }
}
