//
//  InnerShadow.swift
//  third
//
//  Created by Berkay Akpınar on 12.03.2026.
//

import SwiftUI

struct InnerShadow: ViewModifier {
    let color: Color
    let radius: CGFloat
    let offset: CGSize

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(color, lineWidth: 2)
                    .shadow(color: color, radius: radius, x: offset.width, y: offset.height)
                    .blur(radius: 2)
                    .offset(x: offset.width * 0.5, y: offset.height * 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

extension View {
    func innerShadow(color: Color = .black, radius: CGFloat = 4, offset: CGSize = CGSize(width: 0, height: 2)) -> some View {
        modifier(InnerShadow(color: color, radius: radius, offset: offset))
    }
}
