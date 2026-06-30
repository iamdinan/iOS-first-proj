import SwiftUI
internal import Combine

struct LightItUpView: View {

    @State private var vm = LightItUpViewModel()
    @State private var showHighScores = false

    let roundTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            switch vm.phase {
            case .idle:    idleView
            case .playing: playingView
            case .over:    gameOverView
            }

            if vm.showLevelFlash {
                Color.white.opacity(0.35).ignoresSafeArea().allowsHitTesting(false)
                Text("LEVEL \(vm.level.number)")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(vm.level.glowColor)
                    .shadow(color: vm.level.glowColor, radius: 16)
                    .allowsHitTesting(false)
            }
        }
        .onReceive(roundTimer) { _ in vm.tick() }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showHighScores) {
            HighScoreListView(
                title: "Light It Up — Top 10",
                accentColor: .indigo,
                scores: vm.highScoreStore.topScores
            )
        }
    }

    // MARK: - Idle
    var idleView: some View {
        VStack(spacing: 24) {
            Text("Light It Up").font(.largeTitle.bold())
            Text("Tap the glowing card before it goes dark.\nMiss or tap wrong — lose points.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            startButton
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
                VStack(alignment: .trailing, spacing: 2) {
                    Text("LEVEL").font(.caption.bold()).foregroundStyle(.secondary)
                    Text("\(vm.level.number)")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(vm.level.glowColor)
                        .animation(.snappy, value: vm.level.number)
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 48)

            Spacer()

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: vm.level.columns),
                spacing: 12
            ) {
                ForEach(vm.cards) { card in
                    CardView(card: card, glowColor: vm.level.glowColor)
                        .onTapGesture { vm.handleCardTap(card) }
                }
            }
            .padding(.horizontal, 28)
            .animation(.easeInOut(duration: 0.25), value: vm.cards.map(\.id))

            Spacer()

            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(.systemGray5))
                        Capsule()
                            .fill(timerBarColor)
                            .frame(width: geo.size.width * CGFloat(vm.timeLeft) / 60)
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
                .foregroundStyle(.indigo)

            if vm.isNewHighScore {
                Label("New High Score!", systemImage: "trophy.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(.yellow)
            }

            Button(action: vm.resetGame) {
                Text("Play Again")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding(.horizontal, 40)

            Button(action: { showHighScores = true }) {   // ← new
                Label("High Scores", systemImage: "list.number")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }

    // MARK: - Start Button
    var startButton: some View {
        Button(action: vm.startGame) {
            Text("START")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .frame(width: 200, height: 200)
                .background(Color.indigo)
                .foregroundStyle(.white)
                .clipShape(Circle())
                .shadow(color: Color.indigo.opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: vm.score)
    }

    var timerBarColor: Color {
        switch vm.timeLeft {
        case 31...60: return .green
        case 16...30: return .orange
        default:      return .red
        }
    }
}

#Preview { LightItUpView() }
