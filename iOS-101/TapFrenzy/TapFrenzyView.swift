import SwiftUI

struct TapFrenzyView: View {

    @State private var vm = TapFrenzyViewModel()

    let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            switch vm.phase {
            case .idle:    idleView
            case .playing: playingView
            case .over:    gameOverView
            }
        }
        .onReceive(countdownTimer) { _ in vm.tick() }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Idle
    var idleView: some View {
        VStack(spacing: 24) {
            Text("Tap Frenzy").font(.largeTitle.bold())
            Text("Tap as fast as you can!\nGreen = ×2 bonus · Grey = −5 penalty")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            tapButton
        }
        .padding()
    }

    // MARK: - Playing
    var playingView: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SCORE").font(.caption.bold()).foregroundStyle(.secondary)
                    Text("\(vm.score)")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .contentTransition(.numericText())
                        .animation(.snappy, value: vm.score)
                }
                Spacer()
                if vm.multiplier > 1 {
                    Text("×\(vm.multiplier)")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(.orange)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 48)

            Spacer()
            tapButton
            Spacer()

            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(.systemGray5))
                        Capsule()
                            .fill(timerBarColor)
                            .frame(width: geo.size.width * CGFloat(vm.timeLeft) / 10)
                            .animation(.linear(duration: 0.9), value: vm.timeLeft)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 28)

                Text("\(vm.timeLeft)s")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(timerBarColor)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: vm.timeLeft)
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Game Over
    var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Time's Up!").font(.largeTitle.bold())
            Text("Final Score").font(.headline).foregroundStyle(.secondary)
            Text("\(vm.score)")
                .font(.system(size: 72, weight: .black, design: .rounded))
                .foregroundStyle(.blue)

            if vm.highScore > 0 {
                HStack(spacing: 6) {
                    Image(systemName: vm.score == vm.highScore ? "trophy.fill" : "trophy")
                        .foregroundStyle(.yellow)
                    Text(vm.score == vm.highScore ? "New High Score!" : "Best: \(vm.highScore)")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                }
            }

            Button(action: vm.resetGame) {
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

    // MARK: - Tap Button
    var tapButton: some View {
        Button(action: vm.handleTap) {
            Text(vm.phase == .playing ? vm.buttonColor.label : "START")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .frame(width: 200, height: 200)
                .background(vm.phase == .playing ? vm.buttonColor.color : Color.blue)
                .foregroundStyle(.white)
                .clipShape(Circle())
                .shadow(
                    color: (vm.phase == .playing ? vm.buttonColor.color : Color.blue).opacity(0.4),
                    radius: 12, x: 0, y: 6
                )
                .scaleEffect(vm.phase == .playing ? 1.0 : 0.95)
                .animation(.spring(response: 0.15, dampingFraction: 0.5), value: vm.score)
        }
        .disabled(vm.phase == .over)
        .sensoryFeedback(.impact(weight: .medium), trigger: vm.score)
    }

    // MARK: - Helpers
    var timerBarColor: Color {
        switch vm.timeLeft {
        case 7...10: return .green
        case 4...6:  return .orange
        default:     return .red
        }
    }
}

#Preview { TapFrenzyView() }