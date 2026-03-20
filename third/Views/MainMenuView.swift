//
//  MainMenuView.swift
//  third
//
//  Created by Berkay Akpınar on 18.03.2026.
//

import SwiftUI

struct MainMenuView: View {
    @Environment(UserSettings.self) private var userSettings
    @State private var viewModel = MainMenuViewModel()
    @State private var navigationPath: [AppRoute] = []

    // Animation states for circle transition
    @State private var isAnimatingCircle = false
    @State private var circleScale: CGFloat = 1.0
    @State private var lilaOverlayOpacity: Double = 0.0

    var body: some View {
        NavigationStack(path: $navigationPath) {  // path type: [AppRoute]
            GeometryReader { geometry in
                ZStack {
                    // Background
                    Color.appBackground.ignoresSafeArea()

                    // Top circle - positioned from top edge, centered horizontally
                    Circle()
                        .fill(Color.cardLight)
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .position(x: geometry.size.width / 2, y: 0)

                    // Bottom circle - positioned from top edge, centered horizontally
                    Circle()
                        .fill(Color.cardLight)
                        .frame(width: geometry.size.width * 2, height: geometry.size.width * 2)
                        .position(x: geometry.size.width / 2, y: geometry.size.height + geometry.size.width * 0.9)

                    // THIRD text - positioned inside the circle
                    Text("THIRD.")
                        .font(.custom("BebasNeue-Regular", size: 80))
                        .foregroundStyle(Color.appBackground)
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.10)

                    // Buttons VStack - positioned below the circle
                    VStack(spacing: 16) {
                        MainMenuButton(
                            title: AppStrings.continueGame(for: userSettings.selectedLanguage),
                            icon: "play.circle.fill",
                            color: Color.appPrimaryColor,
                            action: { navigateToGame() },
                            disabled: !viewModel.canContinueGame
                        )

                        MainMenuButton(
                            title: AppStrings.newGame(for: userSettings.selectedLanguage),
                            icon: "plus.circle.fill",
                            color: Color.appSuccess,
                            action: { startNewGameWithAnimation() }
                        )

                        MainMenuButton(
                            title: AppStrings.profile(for: userSettings.selectedLanguage),
                            icon: "person.circle.fill",
                            color: Color.appCard,
                            action: { navigationPath.append(AppRoute.profile) }
                        )

                        MainMenuButton(
                            title: AppStrings.settings(for: userSettings.selectedLanguage),
                            icon: "gearshape.fill",
                            color: Color.appCard,
                            action: { navigationPath.append(AppRoute.settings) }
                        )
                    }
                    .padding(.horizontal, 32)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.58)

                    // Animation overlay - expanding circle
                    if isAnimatingCircle {
                        Circle()
                            .fill(Color.cardLight)
                            .frame(width: geometry.size.width * 2, height: geometry.size.width * 2)
                            .scaleEffect(circleScale)
                            .position(
                                x: geometry.size.width / 2,
                                y: geometry.size.height + geometry.size.width * 0.9
                            )
                            .zIndex(1000)
                    }
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .game:
                    GameViewWrapper()
                case .profile:
                    ProfileView()
                        .environment(\.navigationPath, $navigationPath)
                case .settings:
                    SettingsView()
                        .environment(\.navigationPath, $navigationPath)
                }
            }
            .navigationBarHidden(true)
            .toolbar(.hidden, for: .navigationBar)
        }
        // Lila overlay - covers everything including navigation destination, fades out
        .overlay {
            if lilaOverlayOpacity > 0 {
                Color.cardLight
                    .ignoresSafeArea()
                    .opacity(lilaOverlayOpacity)
            }
        }
    }

    // MARK: - Animation Configuration

    private enum AnimationConfig {
        static let circleMaxScale: CGFloat = 3.6
        static let circleAnimationDuration: Double = 0.5
        static let overlayDelay: TimeInterval = 0.4
        static let navigationDelay: TimeInterval = 0.5
        static let fadeOutDelay: TimeInterval = 1.0
        static let fadeOutDuration: TimeInterval = 0.4
    }

    // MARK: - Animation

    private func navigateToGame() {
        // Direct navigation without starting new game
        navigationPath.append(AppRoute.game)
    }

    private func startNewGameWithAnimation() {
        _ = viewModel.startNewGame()
        isAnimatingCircle = true

        withAnimation(.easeInOut(duration: AnimationConfig.circleAnimationDuration)) {
            circleScale = AnimationConfig.circleMaxScale
        }

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(AnimationConfig.overlayDelay))
            lilaOverlayOpacity = 1.0

            try? await Task.sleep(for: .seconds(AnimationConfig.navigationDelay - AnimationConfig.overlayDelay))
            navigationPath.append(AppRoute.game)
            resetAnimationState()

            try? await Task.sleep(for: .seconds(AnimationConfig.fadeOutDelay - AnimationConfig.navigationDelay))
            withAnimation(.easeOut(duration: AnimationConfig.fadeOutDuration)) {
                lilaOverlayOpacity = 0.0
            }
        }
    }

    private func resetAnimationState() {
        isAnimatingCircle = false
        circleScale = 1.0
    }
}

struct MainMenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    var disabled: Bool = false

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title)
                Text(title)
                    .font(.title3)
                    .fontWeight(.medium)
                Spacer()
            }
            .foregroundStyle(disabled ? Color.appPrimaryText.opacity(0.3) : Color.appPrimaryText)
            .padding(.horizontal, 24)
            .padding(.vertical, 22)
            .background(Color.cardLight.opacity(disabled ? 0.5 : 1.0))
            .cornerRadius(16)
        }
        .disabled(disabled)
    }
}

#Preview {
    MainMenuView()
}
