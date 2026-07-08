//
//  GameModeButton.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI

struct GameModeButton: View {
    let mode: GameMode

    var body: some View {
        HStack {
            Image(systemName: mode.icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 4) {
                Text(mode.rawValue)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text(subtitle(for: mode))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(20)
        .background(color(for: mode))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func color(for mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return .blue
        case .lightItUp: return .indigo
        case .quizRush:  return .purple
        }
    }

    private func subtitle(for mode: GameMode) -> String {
        switch mode {
        case .tapFrenzy: return "Tap fast. Beat traps. Build combos."
        case .lightItUp: return "Tap the lit card before it goes dark."
        case .quizRush:  return "Live trivia. Beat the streak."
        }
    }
}
