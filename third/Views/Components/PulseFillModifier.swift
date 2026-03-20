//
//  PulseFillModifier.swift
//  third
//
//  Created by Berkay Akpınar on 12.03.2026.
//

import SwiftUI

struct PulseFillModifier: ViewModifier {
    let isActive: Bool
    @State private var pulsePhase: PulsePhase = .initial

    enum PulsePhase {
        case initial, expanded, settling
    }

    func body(content: Content) -> some View {
        content
            .shadow(
                color: Color.appTarget.opacity(pulseOpacity),
                radius: pulseRadius
            )
            .overlay(
                LinearGradient(
                    colors: [Color.appTarget.opacity(0.2), .clear],
                    startPoint: .leading,
                    endPoint: fillPosition
                )
                .opacity(isActive ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isActive)
            )
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    triggerPulse()
                }
            }
    }

    private var pulseRadius: CGFloat {
        switch pulsePhase {
        case .initial: 6
        case .expanded: 20
        case .settling: 6
        }
    }

    private var pulseOpacity: Double {
        switch pulsePhase {
        case .initial: 0.4
        case .expanded: 0.8
        case .settling: 0.4
        }
    }

    private var fillPosition: UnitPoint {
        isActive ? .trailing : .leading
    }

    private func triggerPulse() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            pulsePhase = .expanded
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                pulsePhase = .settling
            }
        }
    }
}

extension View {
    func pulseFill(isActive: Bool) -> some View {
        modifier(PulseFillModifier(isActive: isActive))
    }
}
