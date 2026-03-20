//
//  GameViewWrapper.swift
//  third
//
//  Creates GameViewModel with session-backed state and passes it to GameView.
//  ViewModel is created immediately (not in onAppear) to avoid white screen.
//

import SwiftUI

struct GameViewWrapper: View {
    @Environment(\.dismiss) private var dismiss
    var customOnDismiss: (() -> Void)? = nil

    // Initialized immediately using SessionManager.shared — never nil, no white screen.
    @State private var viewModel: GameViewModel = GameViewModel(
        initialGameState: SessionManager.shared.currentSession?.gameState ?? GameState(),
        isNewGame: SessionManager.shared.currentSession?.isNewGame ?? true,
        onGameStateChanged: { newState in
            if var session = SessionManager.shared.currentSession {
                session.gameState = newState
                SessionManager.shared.currentSession = session
            }
        },
        onRestartRequested: {
            SessionManager.shared.startNewGame()
        }
    )

    var body: some View {
        GameView(viewModel: viewModel, onDismiss: handleDismiss)
    }

    // MARK: - Private

    private func handleDismiss() {
        if let customOnDismiss {
            customOnDismiss()
        } else {
            dismiss()
        }
    }
}
