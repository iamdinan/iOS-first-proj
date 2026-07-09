//
//  HighScoreListView.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI

struct HighScoreListView: View {
    let title: String
    let accentColor: Color
    let scores: [ScoreEntry]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if scores.isEmpty {
                        Text("No scores yet — play a round!")
                            .foregroundStyle(Theme.textSecondary)
                            .padding(.top, 40)
                    } else {
                        ForEach(Array(scores.enumerated()), id: \.element.id) { index, entry in
                            HStack {
                                Text("#\(index + 1)")
                                    .font(.system(.subheadline, design: .rounded).bold())
                                    .foregroundStyle(index == 0 ? accentColor : Theme.textSecondary)
                                    .frame(width: 40, alignment: .leading)
                                Text("\(entry.score)")
                                    .font(.system(.title3, design: .rounded).bold())
                                    .foregroundStyle(Theme.textPrimary)
                                Spacer()
                                Text(entry.date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .padding(16)
                            .arcadeCard(accent: index == 0 ? accentColor : accentColor.opacity(0.3), glow: index == 0)
                        }
                    }
                }
                .padding()
            }
            .background(Theme.background)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.foregroundStyle(accentColor)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
