//
//  StatsVM.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI

@Observable
final class StatsVM {

    var sessions: [GameSession] = []

    func load() {
        sessions = SessionStore.shared.load()
            .sorted { $0.timestamp > $1.timestamp }
    }

    func deleteAll() {
        SessionStore.shared.deleteAll()
        sessions = []
    }

    // MARK: - Derived
    var totalGames: Int { sessions.count }

    func gamesPlayed(_ mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.count
    }

    func bestScore(_ mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.map(\.score).max() ?? 0
    }

    func totalScore(_ mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.map(\.score).reduce(0, +)
    }

    var recentSessions: [GameSession] {
        Array(sessions.prefix(20))
    }
}
