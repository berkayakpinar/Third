//
//  PopSettleModifier.swift
//  third
//
//  Created by Berkay Akpınar on 12.03.2026.
//

import SwiftUI

struct PopSettleModifier: ViewModifier {
    let isActive: Bool
    @State private var scale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    // Pop to 1.05
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        scale = 1.05
                    }

                    // Settle back to 1.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            scale = 1.0
                        }
                    }
                }
            }
    }
}

extension View {
    func popSettle(isActive: Bool) -> some View {
        modifier(PopSettleModifier(isActive: isActive))
    }
}
