import SwiftUI

@Observable
class LightItUpViewModel {

    // MARK: - State
    var score           = 0
    var timeLeft        = 60
    var phase           = GamePhase.idle
    var cards: [Card]   = []
    var level           = LIULevel.all[0]
    var showLevelFlash  = false

    @ObservationIgnored
    private var litTimer: Timer? = nil
    @ObservationIgnored
    private let storage = LightItUpStorage()

    var highScore: Int {
        get { storage.highScore }
        set { storage.highScore = newValue }
    }

    // MARK: - Tap
    func handleCardTap(_ card: Card) {
        guard phase == .playing else { return }
        if card.isLit {
            score += 1
            if let i = cards.firstIndex(where: { $0.id == card.id }) {
                withAnimation { cards[i].isLit = false }
            }
        } else {
            score = max(0, score - 1)
        }
    }

    // MARK: - Lifecycle
    func startGame() {
        score = 0; timeLeft = 60; phase = .playing
        applyLevel(LIULevel.current(for: timeLeft))
    }

    func tick() {
        guard phase == .playing else { return }
        if timeLeft > 0 {
            timeLeft -= 1
            updateLevelIfNeeded()
        } else {
            endGame()
        }
    }

    func endGame() {
        phase = .over
        litTimer?.invalidate(); litTimer = nil
        if score > highScore { highScore = score }
    }

    func resetGame() {
        phase = .idle; score = 0; timeLeft = 60; cards = []
        litTimer?.invalidate(); litTimer = nil
    }

    // MARK: - Level
    private func updateLevelIfNeeded() {
        let newLevel = LIULevel.current(for: timeLeft)
        guard newLevel.number != level.number else { return }
        applyLevel(newLevel)
        flashLevelOverlay()
    }

    private func applyLevel(_ newLevel: LIULevel) {
        level = newLevel
        litTimer?.invalidate()
        cards = (0..<newLevel.totalCards).map { Card(id: $0) }
        scheduleLitCycle()
    }

    private func scheduleLitCycle() {
        litTimer = Timer.scheduledTimer(withTimeInterval: level.litWindow, repeats: true) { [weak self] _ in
            guard let self, self.phase == .playing else { return }
            withAnimation(.easeInOut(duration: 0.15)) {
                for i in self.cards.indices { self.cards[i].isLit = false }
                let picks = (0..<self.cards.count).shuffled().prefix(self.level.litCount)
                for i in picks { self.cards[i].isLit = true }
            }
        }
    }

    private func flashLevelOverlay() {
        withAnimation(.easeIn(duration: 0.1)) { showLevelFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            withAnimation(.easeOut(duration: 0.3)) { self?.showLevelFlash = false }
        }
    }
}

private class LightItUpStorage: ObservableObject {
    @AppStorage("lightItUpHighScore") var highScore = 0
}