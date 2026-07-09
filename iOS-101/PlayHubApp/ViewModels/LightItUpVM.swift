//
//  LightItUpVM.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI

@Observable
final class LightItUpVM {

    var score          = 0
    var timeLeft       = 60
    var phase          = GamePhase.idle
    var cards:         [Card]    = []
    var level          = LIULevel.all[0]
    var showLevelFlash = false
    var isNewBest      = false
    var lives          = 3
    let maxLives       = 3
    var showLifeLostFlash = false

    @ObservationIgnored var onSessionEnd: ((Int) -> Void)? = nil
    @ObservationIgnored private var litTimer: Timer? = nil

    let highScoreStore = HighScoreStore(key: "lightItUpTopScores")

    func handleCardTap(_ card: Card) {
        guard phase == .playing else { return }
        if card.isLit {
            score += 1
            if let i = cards.firstIndex(where: { $0.id == card.id }) {
                withAnimation { cards[i].isLit = false }
            }
        } else {
            score = max(0, score - 1)
            loseLife()
        }
    }

    func startGame() {
        score = 0; timeLeft = 60; isNewBest = false; phase = .playing
        lives = maxLives
        applyLevel(LIULevel.current(for: timeLeft))
    }

    func tick() {
        guard phase == .playing else { return }
        if timeLeft > 0 { timeLeft -= 1; updateLevelIfNeeded() } else { endGame() }
    }

    func endGame() {
        phase = .over
        litTimer?.invalidate(); litTimer = nil
        isNewBest = score > highScoreStore.best
        highScoreStore.submit(score)
        onSessionEnd?(score)
    }

    func resetGame() {
        phase = .idle; score = 0; timeLeft = 60; cards = []
        lives = maxLives
        litTimer?.invalidate(); litTimer = nil
    }
    
    private func loseLife() {
        guard lives > 0 else { return }
        lives -= 1
        flashLifeLost()
        if lives == 0 {
            endGame()
        }
    }

    private func flashLifeLost() {
        withAnimation(.easeIn(duration: 0.08)) { showLifeLostFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            withAnimation(.easeOut(duration: 0.2)) { self?.showLifeLostFlash = false }
        }
    }

    private func updateLevelIfNeeded() {
        let next = LIULevel.current(for: timeLeft)
        guard next.number != level.number else { return }
        applyLevel(next); flashLevelOverlay()
    }

    private func applyLevel(_ l: LIULevel) {
        level = l; litTimer?.invalidate()
        cards = (0..<l.totalCards).map { Card(id: $0) }
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
