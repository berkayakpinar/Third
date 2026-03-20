//
//  ArchiveView.swift
//  third
//
//  Created by Berkay Akpınar on 18.03.2026.
//

import SwiftUI

struct ArchiveView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                Image(systemName: "archivebox.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)

                Text("Arşiv")
                    .font(.title)
                    .foregroundStyle(.white)

                Text("Geçmiş sorular yakında...")
                    .font(.title3)
                    .foregroundStyle(.gray)

                Spacer()
            }
        }
    }
}

#Preview {
    ArchiveView()
}
