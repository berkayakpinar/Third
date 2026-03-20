//
//  RecessedEffect.swift
//  third
//
//  Created by Berkay Akpınar on 19.03.2026.
//

import SwiftUI

/// Creates a recessed/inset appearance that makes content look embedded into the surface
struct RecessedEffect: ViewModifier {
    let cornerRadius: CGFloat
    let intensity: CGFloat

    init(cornerRadius: CGFloat = 16, intensity: CGFloat = 1.0) {
        self.cornerRadius = cornerRadius
        self.intensity = intensity
    }

    func body(content: Content) -> some View {
        content
            .overlay(
                // Top shadow (darker - creates depth going into surface)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                .black.opacity(0.40 * intensity),
                                .black.opacity(0.20 * intensity),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
    }
}

extension View {
    /// Adds a recessed/inset shadow effect for an embedded appearance
    func recessed(cornerRadius: CGFloat = 16, intensity: CGFloat = 1.0) -> some View {
        modifier(RecessedEffect(cornerRadius: cornerRadius, intensity: intensity))
    }
}
