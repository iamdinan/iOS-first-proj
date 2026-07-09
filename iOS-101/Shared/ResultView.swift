//
//  ResultView.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI

struct ResultView: View {
    let mode: GameMode
    let score: Int
    let isNewBest: Bool
    let accentColor: Color
    let onPlayAgain: () -> Void
    let onShowScores: () -> Void

    private var shareText: String {
        "I just scored \(score) on \(mode.rawValue) in PlayHub — beat that! 🎮"
    }

    var body: some View {
        VStack(spacing: 22) {
            Text("TIME'S UP!")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            VStack(spacing: 4) {
                Text("FINAL SCORE")
                    .font(.system(.caption, design: .rounded).bold())
                    .foregroundStyle(Theme.textSecondary)
                Text("\(score)")
                    .font(.system(size: 80, weight: .black, design: .rounded))
                    .foregroundStyle(accentColor)
                    .shadow(color: accentColor.opacity(0.6), radius: 20)
            }

            if isNewBest {
                Label("NEW HIGH SCORE!", systemImage: "trophy.fill")
                    .font(.system(.subheadline, design: .rounded).bold())
                    .foregroundStyle(.yellow)
                    .shadow(color: .yellow.opacity(0.6), radius: 10)
            }

            ShareLink(item: shareText) {
                Label("Share Score", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(ArcadeGhostButtonStyle(accent: accentColor))
            .padding(.horizontal, 40)

            Button("PLAY AGAIN", action: onPlayAgain)
                .buttonStyle(ArcadeButtonStyle(accent: accentColor))
                .padding(.horizontal, 40)

            Button(action: onShowScores) {
                Label("High Scores", systemImage: "list.number")
            }
            .buttonStyle(ArcadeGhostButtonStyle(accent: Theme.textSecondary))
            .padding(.horizontal, 40)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
    }
}
