//
//  ResultView.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI

struct ResultView: View {
    let mode:         GameMode
    let score:        Int
    let isNewBest:    Bool
    let accentColor:  Color
    let onPlayAgain:  () -> Void
    let onShowScores: () -> Void

    private var shareText: String {
        "I just scored \(score) on \(mode.rawValue) in PlayHub — beat that! 🎮"
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Time's Up!")
                .font(.largeTitle.bold())
            Text("Final Score")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("\(score)")
                .font(.system(size: 72, weight: .black, design: .rounded))
                .foregroundStyle(accentColor)

            if isNewBest {
                Label("New High Score!", systemImage: "trophy.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(.yellow)
            }

            // Share
            ShareLink(item: shareText) {
                Label("Share Score", systemImage: "square.and.arrow.up")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)

            Button(action: onPlayAgain) {
                Text("Play Again")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding(.horizontal, 40)

            Button(action: onShowScores) {
                Label("High Scores", systemImage: "list.number")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}
