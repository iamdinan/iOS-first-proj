import SwiftUI
internal import Combine

// MARK: - Button Color State
enum ButtonColor: CaseIterable {
    case normal, green, grey

    var color: Color {
        switch self {
        case .normal: return .blue
        case .green:  return .green
        case .grey:   return Color(.systemGray3)
        }
    }

    var label: String {
        switch self {
        case .normal: return "TAP!"
        case .green:  return "BONUS!"
        case .grey:   return "TRAP!"
        }
    }
}

// MARK: - Game State
enum GamePhase {
    case idle, playing, over
}

// MARK: - ContentView
struct ContentView: View {

    // Main state
    @State private var score: Int = 0
    @State private var timeLeft: Int = 10
    @State private var phase: GamePhase = .idle

    // Combo system
    @State private var multiplier: Int = 1
    @State private var lastTapTime: Date? = nil

    // Trap color system
    @State private var buttonColor: ButtonColor = .normal
    @State private var colorTimer: Timer? = nil
    
    // high score state
    @State private var highScore: Int = 0


    // Countdown
    let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            switch phase {
            case .idle:
                idleView
            case .playing:
                playingView
            case .over:
                gameOverView
            }
        }
        .onReceive(countdownTimer) { _ in
            guard phase == .playing else { return }
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                endGame()
            }
        }
    }

    // MARK: - Homescreen View
    var idleView: some View {
        VStack(spacing: 24) {
            Text("TapFrenzy")
                .font(.largeTitle.bold())
            Text("Tap as fast as you can!\nGreen = ×2 bonus · Grey = −5 penalty")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            tapButton
        }
        .padding()
    }

    // MARK: - Gamescreen View
    var playingView: some View {
        VStack(spacing: 0) {

            // Score and multiplier row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SCORE")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text("\(score)")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .contentTransition(.numericText())
                        .animation(.snappy, value: score)
                }
                Spacer()
                if multiplier > 1 {
                    Text("×\(multiplier)")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(.orange)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 48)

            Spacer()

            //tap button
            tapButton

            Spacer()

            // Timer and countdown
            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(.systemGray5))
                        Capsule()
                            .fill(timerBarColor)
                            .frame(width: geo.size.width * CGFloat(timeLeft) / 10)
                            .animation(.linear(duration: 0.9), value: timeLeft)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 28)

                Text("\(timeLeft)s")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(timerBarColor)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: timeLeft)
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Gameover View
    var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Time's Up!")
                .font(.largeTitle.bold())

            Text("Final Score")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("\(score)")
                .font(.system(size: 72, weight: .black, design: .rounded))
                .foregroundStyle(.blue)

            //highscore panel
            if highScore > 0 {
                HStack(spacing: 6) {
                    Image(systemName: score == highScore ? "trophy.fill" : "trophy")
                        .foregroundStyle(.yellow)
                    Text(score == highScore ? "New High Score!" : "Best: \(highScore)")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                }
            }

            Button(action: resetGame) {
                Text("Play Again")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding(.horizontal, 40)
            .padding(.top, 12)
        }
        .padding()
    }

    // MARK: - Tap Button (shared)
    var tapButton: some View {
        Button(action: handleTap) {
            Text(phase == .playing ? buttonColor.label : "START")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .frame(width: 200, height: 200)
                .background(phase == .playing ? buttonColor.color : Color.blue)
                .foregroundStyle(.white)
                .clipShape(Circle())
                .shadow(color: (phase == .playing ? buttonColor.color : Color.blue).opacity(0.4),
                        radius: 12, x: 0, y: 6)
                .scaleEffect(phase == .playing ? 1.0 : 0.95)
                .animation(.spring(response: 0.15, dampingFraction: 0.5), value: score)
        }
        .disabled(phase == .over)
        .sensoryFeedback(.impact(weight: .medium), trigger: score)
    }

    // MARK: - Tap Logic
    func handleTap() {
        if phase == .idle {
            startGame()
            return
        }
        guard phase == .playing, timeLeft > 0 else { return }

        // Combo logic
        let now = Date()
        if let last = lastTapTime, now.timeIntervalSince(last) <= 0.5 {
            multiplier = min(multiplier + 1, 8)
        } else {
            multiplier = 1
        }
        lastTapTime = now

        // Score with trap color
        switch buttonColor {
        case .normal:
            score += 1 * multiplier
        case .green:
            score += 2 * multiplier
        case .grey:
            score = max(0, score - 5)
            multiplier = 1               // combo break when trap hit
        }
    }

    // MARK: - Game Lifecycle
    func startGame() {
        score = 0
        timeLeft = 10
        multiplier = 1
        lastTapTime = nil
        buttonColor = .normal
        phase = .playing
        scheduleColorChanges()
    }

    func endGame() {
        phase = .over
        colorTimer?.invalidate()
        colorTimer = nil
        if score > highScore { highScore = score }
    }

    func resetGame() {
        phase = .idle
        score = 0
        timeLeft = 10
        multiplier = 1
        buttonColor = .normal
    }

    // MARK: - Color Trap Scheduler
    func scheduleColorChanges() {
        colorTimer?.invalidate()
        let delay = Double.random(in: 1.5...3.0)
        colorTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            guard phase == .playing else { return }

            // 25% green, 25% grey, 50% normal
            let roll = Int.random(in: 0...3)
            withAnimation(.easeInOut(duration: 0.25)) {
                buttonColor = [.green, .grey, .normal, .normal][roll]
            }

            // Hold special color couple seconds and revert
            let holdTime = Double.random(in: 1.0...2.0)
            Timer.scheduledTimer(withTimeInterval: holdTime, repeats: false) { _ in
                guard phase == .playing else { return }
                withAnimation(.easeInOut(duration: 0.25)) {
                    buttonColor = .normal
                }
                scheduleColorChanges()  // schedule next change
            }
        }
    }

    // MARK: - Helpers
    var timerBarColor: Color {
        switch timeLeft {
        case 7...10: return .green
        case 4...6:  return .orange
        default:     return .red
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
