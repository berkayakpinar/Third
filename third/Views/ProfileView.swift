//
//  ProfileView.swift
//  third
//
//  Created by Berkay Akpınar on 18.03.2026.
//

import SwiftUI

private struct NavigationPathKey: EnvironmentKey {
    static let defaultValue: Binding<[AppRoute]>? = nil
}

extension EnvironmentValues {
    var navigationPath: Binding<[AppRoute]>? {
        get { self[NavigationPathKey.self] }
        set { self[NavigationPathKey.self] = newValue }
    }
}

struct ProfileView: View {
    @Environment(\.navigationPath) private var navigationPath
    @Environment(UserSettings.self) private var userSettings
    @State private var viewModel = ProfileViewModel()
    @State private var showResetConfirmation = false

    var body: some View {
        ZStack {
            // Background
            Color.appBackground.ignoresSafeArea()

            // Back button (top left)
            VStack {
                HStack {
                    Button {
                        navigationPath?.wrappedValue.removeLast()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundStyle(Color.appForeground)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.leading)
                .padding(.top, 8)
                Spacer()
            }
            .zIndex(1)

            // Main content
            ScrollView {
                VStack(spacing: 16) {
                    Spacer().frame(height: 80)

                    // User Name
                    VStack(spacing: 12) {
                        Text(viewModel.username)
                            .font(.custom("BebasNeue-Regular", size: 48))
                            .foregroundStyle(Color.appForeground)

                        Button {
                            viewModel.startEditingUsername()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "pencil")
                                Text(AppStrings.edit(for: userSettings.selectedLanguage))
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.appForeground.opacity(0.7))
                        }
                    }

                    Spacer().frame(height: 30)

                    // Stats - Vertical full width cards
                    VStack(spacing: 12) {
                        StatCard(
                            icon: "trophy.fill",
                            title: AppStrings.highScore(for: userSettings.selectedLanguage),
                            value: String(viewModel.highScore)
                        )

                        StatCard(
                            icon: "target",
                            title: AppStrings.furthestQuestion(for: userSettings.selectedLanguage),
                            value: String(viewModel.furthestQuestion)
                        )

                        StatCard(
                            icon: "gamecontroller.fill",
                            title: AppStrings.totalGames(for: userSettings.selectedLanguage),
                            value: String(viewModel.totalGamesPlayed)
                        )

                        StatCard(
                            icon: "chart.bar.fill",
                            title: AppStrings.averageScore(for: userSettings.selectedLanguage),
                            value: String(viewModel.averageScore)
                        )

                        StatCard(
                            icon: "flame.fill",
                            title: AppStrings.longestStreak(for: userSettings.selectedLanguage),
                            value: String(viewModel.longestStreak)
                        )
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 20)

                    // Reset Button
                    Button {
                        showResetConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text(AppStrings.resetStats(for: userSettings.selectedLanguage))
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.appError)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(Color.cardLight)
                        .cornerRadius(16)
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $viewModel.isEditingUsername) {
            UsernameEditSheet(viewModel: viewModel)
        }
        .confirmationDialog(AppStrings.resetStatsConfirmTitle(for: userSettings.selectedLanguage), isPresented: $showResetConfirmation, titleVisibility: .visible) {
            Button(AppStrings.reset(for: userSettings.selectedLanguage), role: .destructive) {
                viewModel.resetStats()
            }
            Button(AppStrings.cancel(for: userSettings.selectedLanguage), role: .cancel) {}
        } message: {
            Text(AppStrings.resetStatsConfirmMessage(for: userSettings.selectedLanguage))
        }
    }
}

// MARK: - Profile Card Style Modifier

struct ProfileCardStyle: ViewModifier {
    let verticalPadding: CGFloat

    init(verticalPadding: CGFloat = 10) {
        self.verticalPadding = verticalPadding
    }

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 20)
            .padding(.vertical, verticalPadding)
            .background(Color.cardLight)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.3), radius: 8, x: 4, y: 4)
    }
}

extension View {
    func profileCardStyle(verticalPadding: CGFloat = 10) -> some View {
        modifier(ProfileCardStyle(verticalPadding: verticalPadding))
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.appBackground)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appPrimaryText.opacity(0.6))

                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.appPrimaryText)
            }

            Spacer()
        }
        .profileCardStyle()
    }
}

// MARK: - Username Edit Sheet

struct UsernameEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserSettings.self) private var userSettings
    @Bindable var viewModel: ProfileViewModel

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Text(AppStrings.editName(for: userSettings.selectedLanguage))
                        .font(.custom("BebasNeue-Regular", size: 36))
                        .foregroundStyle(Color.appForeground)

                    Text(AppStrings.maxCharacters(for: userSettings.selectedLanguage))
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appForeground.opacity(0.7))
                }

                // Input
                TextField("", text: $viewModel.usernameInput)
                    .font(.title2)
                    .foregroundStyle(Color.appPrimaryText)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.cardLight)
                    .cornerRadius(16)
                    .overlay(
                        Text(AppStrings.usernamePlaceholder(for: userSettings.selectedLanguage))
                            .foregroundStyle(Color.appPrimaryText.opacity(0.3))
                            .font(.title2)
                            .opacity(viewModel.usernameInput.isEmpty ? 1 : 0)
                    )
                    .onAppear {
                        viewModel.usernameInput = viewModel.username
                    }

                // Character count
                HStack {
                    Spacer()
                    Text("\(viewModel.usernameInput.count)/20")
                        .font(.system(size: 12))
                        .foregroundStyle(viewModel.usernameInput.count > 20 ? Color.appError : Color.appForeground.opacity(0.7))
                }
                .padding(.horizontal)

                // Buttons
                VStack(spacing: 12) {
                    Button {
                        if viewModel.saveUsername() {
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text(AppStrings.save(for: userSettings.selectedLanguage))
                        }
                        .font(.title3)
                        .foregroundStyle(Color.appPrimaryText)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color.appPrimaryColor)
                        .cornerRadius(16)
                    }
                    .disabled(!viewModel.isUsernameInputValid)
                    .opacity(viewModel.isUsernameInputValid ? 1 : 0.5)

                    Button {
                        dismiss()
                    } label: {
                        Text(AppStrings.cancel(for: userSettings.selectedLanguage))
                            .font(.title3)
                            .foregroundStyle(Color.appForeground)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)
        }
        .presentationDetents([.height(400)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    ProfileView()
}
