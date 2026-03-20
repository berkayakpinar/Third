//
//  ShakeBleedModifier.swift
//  third
//
//  Created by Berkay Akpınar on 12.03.2026.
//

import SwiftUI

// MARK: - Shake Effect
struct ShakeModifier: ViewModifier {
    let trigger: Bool
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    // Create rapid shake animation (5 cycles)
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) {
                        offset = 8
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) {
                            offset = -8
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                        withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) {
                            offset = 8
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) {
                            offset = -8
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                        withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) {
                            offset = 8
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            offset = 0
                        }
                    }
                }
            }
    }
}

extension View {
    func shake(trigger: Bool) -> some View {
        modifier(ShakeModifier(trigger: trigger))
    }
}

// MARK: - Bleed Overlay
struct BleedOverlay: ViewModifier {
    let isActive: Bool
    let color: Color

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        RadialGradient(
                            colors: [color, .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 150
                        )
                    )
                    .opacity(isActive ? 1 : 0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.65), value: isActive)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

extension View {
    func bleedOverlay(isActive: Bool, color: Color) -> some View {
        modifier(BleedOverlay(isActive: isActive, color: color))
    }
}
