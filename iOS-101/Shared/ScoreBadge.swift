//
//  ScoreBadge.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI

struct ScoreBadge: View {
    let mode:  GameMode
    let score: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: mode.icon)
                .font(.caption.bold())
            Text("\(score)")
                .font(.caption.bold())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(badgeColor.opacity(0.15))
        .foregroundStyle(badgeColor)
        .clipShape(Capsule())
    }

    private var badgeColor: Color {
        switch mode {
        case .tapFrenzy: return .blue
        case .lightItUp: return .indigo
        case .quizRush:  return .purple
        }
    }
}

#Preview {
    HStack {
        ScoreBadge(mode: .tapFrenzy, score: 42)
        ScoreBadge(mode: .lightItUp, score: 18)
        ScoreBadge(mode: .quizRush,  score: 95)
    }
    .padding()
}
