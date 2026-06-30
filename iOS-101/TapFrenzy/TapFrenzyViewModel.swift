@Observable
class TapFrenzyViewModel {

    var score       = 0
    var timeLeft    = 10
    var phase       = GamePhase.idle
    var multiplier  = 1
    var buttonColor = ButtonColor.normal

    @ObservationIgnored
    private var lastTapTime: Date? = nil
    @ObservationIgnored
    private var colorTimer: Timer? = nil

    let highScoreStore = HighScoreStore(key: "tapFrenzyTopScores")

    var isNewHighScore = false   // for game-over messaging

    // MARK: - Tap
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

    // MARK: - Lifecycle
    func startGame() {
        score = 0; timeLeft = 10; multiplier = 1
        lastTapTime = nil; buttonColor = .normal; phase = .playing
        isNewHighScore = false
        scheduleColorChanges()
    }

    func tick() {
        guard phase == .playing else { return }
        if timeLeft > 0 { timeLeft -= 1 } else { endGame() }
    }

    func endGame() {
        phase = .over
        colorTimer?.invalidate(); colorTimer = nil
        isNewHighScore = score > highScoreStore.best
        highScoreStore.submit(score)
    }

    func resetGame() {
        phase = .idle; score = 0; timeLeft = 10
        multiplier = 1; buttonColor = .normal
    }

    // MARK: - Color Trap
    private func scheduleColorChanges() {
        colorTimer?.invalidate()
        let delay = Double.random(in: 1.5...3.0)
        colorTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            guard let self, self.phase == .playing else { return }
            let roll = Int.random(in: 0...3)
            withAnimation(.easeInOut(duration: 0.25)) {
                self.buttonColor = [.green, .grey, .normal, .normal][roll]
            }
            let holdTime = Double.random(in: 1.0...2.0)
            Timer.scheduledTimer(withTimeInterval: holdTime, repeats: false) { [weak self] _ in
                guard let self, self.phase == .playing else { return }
                withAnimation(.easeInOut(duration: 0.25)) { self.buttonColor = .normal }
                self.scheduleColorChanges()
            }
        }
    }
}