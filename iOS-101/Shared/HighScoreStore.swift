import SwiftUI

struct ScoreEntry: Identifiable, Codable {
    let id: UUID
    let score: Int
    let date: Date

    init(score: Int, date: Date = Date()) {
        self.id = UUID()
        self.score = score
        self.date = date
    }
}

@Observable
class HighScoreStore {

    private let storageKey: String
    private let maxEntries = 10

    var topScores: [ScoreEntry] = []

    init(key: String) {
        self.storageKey = key
        load()
    }

    var best: Int { topScores.first?.score ?? 0 }

    @discardableResult
    func submit(_ score: Int) -> Bool {
        guard score > 0 else { return false }

        let qualifies = topScores.count < maxEntries || score > (topScores.last?.score ?? 0)
        guard qualifies else { return false }

        topScores.append(ScoreEntry(score: score))
        topScores.sort { $0.score > $1.score }
        if topScores.count > maxEntries {
            topScores.removeLast(topScores.count - maxEntries)
        }
        save()
        return true
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([ScoreEntry].self, from: data)
        else { return }
        topScores = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(topScores) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}