//
//  GameSession.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import Foundation

struct GameSession: Identifiable, Codable, Hashable {
    let id: UUID
    let mode: GameMode
    let score: Int
    let timestamp: Date
    let latitude: Double
    let longitude: Double

    init(mode: GameMode, score: Int, latitude: Double = 0, longitude: Double = 0) {
        self.id        = UUID()
        self.mode      = mode
        self.score     = score
        self.timestamp = Date()
        self.latitude  = latitude
        self.longitude = longitude
    }
}

// MARK: - Persistence
final class SessionStore {
    static let shared = SessionStore()
    private let key = "gameSessions"

    private init() {}

    func load() -> [GameSession] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([GameSession].self, from: data)
        else { return [] }
        return decoded
    }

    func append(_ session: GameSession) {
        var all = load()
        all.append(session)
        if let data = try? JSONEncoder().encode(all) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func deleteAll() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
