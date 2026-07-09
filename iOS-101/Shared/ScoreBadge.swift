//
//  ScoreBadge.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI

struct ScoreBadge: View {
    let mode: GameMode
    let score: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: mode.icon).font(.caption.bold())
            Text("\(score)").font(.system(.caption, design: .rounded).bold())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(mode.themeColor.opacity(0.18))
        .foregroundStyle(mode.themeColor)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(mode.themeColor.opacity(0.6), lineWidth: 1))
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
