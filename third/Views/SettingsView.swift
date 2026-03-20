//
//  SettingsView.swift
//  third
//
//  Created by Berkay Akpınar on 18.03.2026.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.navigationPath) private var navigationPath
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        ZStack {
            // Background
            Color.appBackground.ignoresSafeArea()

            // Back button (top left)
            VStack {
                HStack {
                    Button {
                        if let navigationPath = navigationPath {
                            navigationPath.wrappedValue.removeLast()
                        } else {
                            dismiss()
                        }
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

                    // Header
                    VStack(spacing: 12) {
                        Text("Ayarlar")
                            .font(.custom("BebasNeue-Regular", size: 48))
                            .foregroundStyle(Color.appForeground)
                    }

                    Spacer().frame(height: 30)

                    // All Settings Cards
                    VStack(spacing: 12) {
                        SettingsToggleCard(
                            icon: "speaker.wave.2.fill",
                            title: "Ses Efektleri",
                            description: "Oyun içi sesleri aç/kapat",
                            isOn: viewModel.settings.soundEffectsEnabled,
                            action: {
                                viewModel.toggleSoundEffects()
                            }
                        )

                        SettingsLanguageToggleCard(
                            icon: "globe.fill",
                            title: "Dil Seçeneği",
                            currentValue: "\(viewModel.settings.selectedLanguage.flag) \(viewModel.settings.selectedLanguage.displayName)"
                        ) {
                            viewModel.toggleLanguage()
                        }

                        SettingsInfoCard(
                            icon: "info.circle.fill",
                            title: "Sürüm",
                            value: viewModel.settings.appVersion
                        )

                        SettingsInfoCard(
                            icon: "person.crop.circle.badge.checkmark",
                            title: "Developer",
                            value: viewModel.settings.developerName
                        )

                        SettingsButtonCard(
                            icon: "arrow.counterclockwise",
                            title: "Varsayılan Ayarlara Dön",
                            color: Color.appError
                        ) {
                            viewModel.showResetConfirmation = true
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("Ayarları Sıfırla", isPresented: $viewModel.showResetConfirmation, titleVisibility: .visible) {
            Button("Sıfırla", role: .destructive) {
                viewModel.settings.resetToDefaults()
            }
            Button("İptal", role: .cancel) {}
        } message: {
            Text("Tüm ayarlar varsayılan değerlere dönecek. Emin misiniz?")
        }
    }
}

// MARK: - Settings Card Style Modifier

struct SettingsCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(minHeight: 64)
            .background(Color.cardLight)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.3), radius: 8, x: 4, y: 4)
    }
}

extension View {
    func settingsCardStyle() -> some View {
        modifier(SettingsCardStyle())
    }
}

// MARK: - Settings Toggle Card

struct SettingsToggleCard: View {
    let icon: String
    let title: String
    let description: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.appBackground)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.appPrimaryText)

                Text(description)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appPrimaryText.opacity(0.6))
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { isOn },
                set: { _ in action() }
            ))
            .tint(Color.appBackground)
        }
        .settingsCardStyle()
    }
}

// MARK: - Settings Language Toggle Card

struct SettingsLanguageToggleCard: View {
    let icon: String
    let title: String
    let currentValue: String
    let action: () -> Void

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        } label: {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(Color.appBackground)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appPrimaryText.opacity(0.6))

                    Text(currentValue)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.appPrimaryText)
                }

                Spacer()

                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.appBackground.opacity(0.6))
            }
            .settingsCardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Button Card

struct SettingsButtonCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 40)

                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(color)

                Spacer()
            }
            .settingsCardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Info Card

struct SettingsInfoCard: View {
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
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.appPrimaryText)
            }

            Spacer()
        }
        .settingsCardStyle()
    }
}

#Preview {
    SettingsView()
}
