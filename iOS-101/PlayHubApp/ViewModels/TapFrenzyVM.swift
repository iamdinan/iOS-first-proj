//
//  TapFrenzyVM.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI

@Observable
final class TapFrenzyVM {

    var score       = 0
    var timeLeft    = 10
    var phase       = GamePhase.idle
    var multiplier  = 1
    var buttonColor = ButtonColor.normal
    var isNewBest   = false
    var buttonPosition = CGPoint(x: 0.5, y: 0.5)


    @ObservationIgnored var onSessionEnd: ((Int) -> Void)? = nil

    @ObservationIgnored private var lastTapTime: Date?   = nil
    @ObservationIgnored private var colorTimer:  Timer?  = nil

    let highScoreStore = HighScoreStore(key: "tapFrenzyTopScores")

    func handleTap() {
        if phase == .idle { startGame(); return }
        guard phase == .playing, timeLeft > 0 else { return }

        let now = Date()
        if let last = lastTapTime, now.timeIntervalSince(last) <= 0.5 {
            multiplier = min(multiplier + 1, 8)
        } else {
            multiplier = 1
        }
        lastTapTime = now

        switch buttonColor {
        case .normal: score += 1 * multiplier
        case .green:  score += 2 * multiplier
        case .grey:   score = max(0, score - 5); multiplier = 1
        }
    }

    func startGame() {
        score = 0; timeLeft = 10; multiplier = 1
        lastTapTime = nil; buttonColor = .normal
        buttonPosition = CGPoint(x: 0.5, y: 0.5)
        phase = .playing; isNewBest = false
        scheduleColorChanges()
    }

    func tick() {
        guard phase == .playing else { return }
        if timeLeft > 0 { timeLeft -= 1 } else { endGame() }
    }

    func endGame() {
        phase = .over
        colorTimer?.invalidate(); colorTimer = nil
        isNewBest = score > highScoreStore.best
        highScoreStore.submit(score)
        onSessionEnd?(score)
    }

    func resetGame() {
        phase = .idle; score = 0; timeLeft = 10
        multiplier = 1; buttonColor = .normal
    }

    private func scheduleColorChanges() {
            colorTimer?.invalidate()
            let delay = Double.random(in: 1.5...3.0)
            colorTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
                guard let self, self.phase == .playing else { return }
                let roll = Int.random(in: 0...3)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    self.buttonColor = [.green, .grey, .normal, .normal][roll]
                    self.buttonPosition = CGPoint(
                        x: Double.random(in: 0.15...0.85),
                        y: Double.random(in: 0.15...0.85)
                    )
                }
                let hold = Double.random(in: 1.0...2.0)
                Timer.scheduledTimer(withTimeInterval: hold, repeats: false) { [weak self] _ in
                    guard let self, self.phase == .playing else { return }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        self.buttonColor = .normal
                        self.buttonPosition = CGPoint(
                            x: Double.random(in: 0.15...0.85),
                            y: Double.random(in: 0.15...0.85)
                        )
                    }
                    self.scheduleColorChanges()
                }
            }
        }
}
