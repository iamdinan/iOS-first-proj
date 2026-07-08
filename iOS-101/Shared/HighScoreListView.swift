//
//  HighScoreListView.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI

struct HighScoreListView: View {
    let title:       String
    let accentColor: Color
    let scores:      [ScoreEntry]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if scores.isEmpty {
                    Text("No scores yet — play a round!")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(scores.enumerated()), id: \.element.id) { index, entry in
                        HStack {
                            Text("#\(index + 1)")
                                .font(.subheadline.bold())
                                .foregroundStyle(index == 0 ? accentColor : .secondary)
                                .frame(width: 36, alignment: .leading)
                            Text("\(entry.score)")
                                .font(.title3.bold())
                            Spacer()
                            Text(entry.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
