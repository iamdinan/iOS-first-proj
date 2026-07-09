//
//  StatsTab.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI
import Charts

struct StatsTab: View {
    @State private var vm = StatsVM()
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            List {
                // Per-mode summary cards
                Section("Summary") {
                    ForEach(GameMode.allCases, id: \.self) { mode in
                        ModeSummaryRow(
                            mode: mode,
                            games: vm.gamesPlayed(mode),
                            best:  vm.bestScore(mode)
                        )
                    }
                }

                // Bar chart
                if !vm.sessions.isEmpty {
                    Section("Scores by Mode") {
                        Chart(vm.sessions) { session in
                            BarMark(
                                x: .value("Mode",  session.mode.rawValue),
                                y: .value("Score", session.score)
                            )
                            .foregroundStyle(by: .value("Mode", session.mode.rawValue))
                        }
                        .frame(height: 200)
                        .padding(.vertical, 8)
                    }
                }

                // Recent games
                if !vm.recentSessions.isEmpty {
                    Section("Recent Games") {
                        ForEach(vm.recentSessions) { session in
                            HStack {
                                Image(systemName: session.mode.icon)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(session.mode.rawValue)
                                        .font(.subheadline.bold())
                                    Text(session.timestamp, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                ScoreBadge(mode: session.mode, score: session.score)

                            }
                        }
                    }
                }
            }
            .navigationTitle("Stats")
            .onAppear { vm.load() }
            .confirmationDialog("Reset all stats?",
                                isPresented: $showResetConfirm,
                                titleVisibility: .visible) {
                Button("Reset Everything", role: .destructive) { vm.deleteAll() }
            } message: {
                Text("This cannot be undone.")
            }
        }
    }
}

private struct ModeSummaryRow: View {
    let mode:  GameMode
    let games: Int
    let best:  Int

    var body: some View {
        HStack {
            Image(systemName: mode.icon)
                .foregroundStyle(.secondary)
                .frame(width: 28)
            Text(mode.rawValue)
                .font(.subheadline.bold())
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Best: \(best)")
                    .font(.caption.bold())
                Text("\(games) games")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
