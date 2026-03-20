//
//  SquircleBox.swift
//  third
//
//  Created by Berkay Akpınar on 12.03.2026.
//

import SwiftUI

struct SquircleBox<Content: View>: View {
    let cornerRadius: CGFloat
    let tintColor: Color
    let borderColor: Color
    let solidFill: Color?
    let showMaterial: Bool
    let content: Content

    init(
        cornerRadius: CGFloat = 16,
        tintColor: Color,
        borderColor: Color,
        solidFill: Color? = nil,
        showMaterial: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.tintColor = tintColor
        self.borderColor = borderColor
        self.solidFill = solidFill
        self.showMaterial = showMaterial
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Layer 0: Solid fill (base background)
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(solidFill ?? Color.cardLight)
                .shadow(color: .black.opacity(0.65), radius: 15, x: 12, y: 10)
                .shadow(color: .white.opacity(0.25), radius: 8, x: -3, y: -3)

            // Layer 0.25: Tint overlay (for trap/target)
            if solidFill == nil {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(tintColor.opacity(0.15))
            }

            // Layer 0.5: Border stroke
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(borderColor, lineWidth: 5)

            // Layer 1: Content
            content
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SquircleBox(
            tintColor: .red,
            borderColor: .red
        ) {
            Text("Trap")
                .font(.headline)
                .foregroundStyle(Color.appPrimaryText)
                .frame(height: 60)
        }

        SquircleBox(
            tintColor: .green,
            borderColor: .green
        ) {
            Text("Target")
                .font(.headline)
                .foregroundStyle(Color.appPrimaryText)
                .frame(height: 60)
        }

        SquircleBox(
            tintColor: .gray.opacity(0.6),
            borderColor: .gray
        ) {
            Text("Normal")
                .font(.headline)
                .foregroundStyle(Color.appPrimaryText)
                .frame(height: 60)
        }
    }
    .padding()
    .background(
        LinearGradient(
            colors: [
                Color.appPrimaryColor.opacity(0.4),
                Color.appBackgroundColor,
                Color.cardDark.opacity(0.3)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    )
}
