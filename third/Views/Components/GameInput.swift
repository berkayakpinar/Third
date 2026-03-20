//
//  GameInput.swift
//  third
//
//  Created by Berkay Akpınar on 12.03.2026.
//

import SwiftUI

struct GameInput: View {
    @Binding var inputText: String
    let onSubmit: () -> Void
    @FocusState private var isInputFocused: Bool

    var body: some View {
        HStack(spacing: 0) {
            TextField("Tahminini yaz...", text: $inputText)
                .textFieldStyle(.plain)
                .font(.system(size: 16))
                .padding(.leading, 20)
                .foregroundStyle(Color.appPrimaryText)
                .tint(Color.appPrimaryText)
                .submitLabel(.done)
                .onSubmit {
                    onSubmit()
                }

            Button(action: onSubmit) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(inputText.isEmpty ? Color.appPrimaryText.opacity(0.3) : Color.appPrimaryText)
                    .frame(width: 50, height: 50)
                    .background(Color.cardLight.opacity(inputText.isEmpty ? 0.5 : 1.0))
            }
            .disabled(inputText.isEmpty)
        }
        .frame(height: 50)
        .background(Color.cardLight)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
        .animation(.easeOut(duration: 0.2), value: inputText.isEmpty)
    }
}
