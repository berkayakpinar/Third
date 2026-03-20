//
//  ProfileView.swift
//  third
//
//  Created by Berkay Akpınar on 18.03.2026.
//

import SwiftUI

private struct NavigationPathKey: EnvironmentKey {
    static let defaultValue: Binding<NavigationPath>? = nil
}

extension EnvironmentValues {
    var navigationPath: Binding<NavigationPath>? {
        get { self[NavigationPathKey.self] }
        set { self[NavigationPathKey.self] = newValue }
    }
}

struct ProfileView: View {
    @Environment(\.navigationPath) private var navigationPath
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
                                Text("Düzenle")
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
                            title: "En Yüksek Skor",
                            value: String(viewModel.highScore)
                        )

                        StatCard(
                            icon: "target",
                            title: "En Uzak Soru",
                            value: String(viewModel.furthestQuestion)
                        )

                        StatCard(
                            icon: "gamecontroller.fill",
                            title: "Toplam Oyun",
                            value: String(viewModel.totalGamesPlayed)
                        )

                        StatCard(
                            icon: "chart.bar.fill",
                            title: "Ortalama Skor",
                            value: String(viewModel.averageScore)
                        )

                        StatCard(
                            icon: "flame.fill",
                            title: "En Uzun Seri",
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
                            Text("İstatistik Sıfırla")
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
        .confirmationDialog("İstatistik Sıfırla", isPresented: $showResetConfirmation, titleVisibility: .visible) {
            Button("Sıfırla", role: .destructive) {
                viewModel.resetStats()
            }
            Button("İptal", role: .cancel) {}
        } message: {
            Text("Tüm istatistikler silinecek ve sıfırlanacak. Emin misiniz?")
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
    var viewModel: ProfileViewModel
    @State private var usernameText = ""

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Text("İsim Düzenle")
                        .font(.custom("BebasNeue-Regular", size: 36))
                        .foregroundStyle(Color.appForeground)

                    Text("Maksimum 20 karakter")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appForeground.opacity(0.7))
                }

                // Input
                TextField("", text: $usernameText)
                    .font(.title2)
                    .foregroundStyle(Color.appPrimaryText)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.cardLight)
                    .cornerRadius(16)
                    .overlay(
                        Text(usernameText.isEmpty ? "Kullanıcı adı" : "")
                            .foregroundStyle(Color.appPrimaryText.opacity(0.3))
                            .font(.title2)
                            .offset(x: usernameText.isEmpty ? 0 : -1000)
                    )
                    .onAppear {
                        usernameText = viewModel.username
                    }

                // Character count
                HStack {
                    Spacer()
                    Text("\(usernameText.count)/20")
                        .font(.system(size: 12))
                        .foregroundStyle(usernameText.count > 20 ? Color.appError : Color.appForeground.opacity(0.7))
                }
                .padding(.horizontal)

                // Buttons
                VStack(spacing: 12) {
                    Button {
                        viewModel.userProfile.username = usernameText.trimmingCharacters(in: .whitespacesAndNewlines)
                        viewModel.userProfile.save()
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Kaydet")
                        }
                        .font(.title3)
                        .foregroundStyle(Color.appPrimaryText)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color.appPrimaryColor)
                        .cornerRadius(16)
                    }
                    .disabled(usernameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || usernameText.count > 20)
                    .opacity(usernameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || usernameText.count > 20 ? 0.5 : 1)

                    Button {
                        dismiss()
                    } label: {
                        Text("İptal")
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
