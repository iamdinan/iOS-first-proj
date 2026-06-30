import SwiftUI

struct QuizRushView: View {

    @StateObject private var vm = QuizRushViewModel()
    @State private var showHighScores = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            switch vm.state {
            case .loading:
                loadingView
            case .failed(let message):
                errorView(message)
            case .loaded:
                if vm.isRoundComplete {
                    resultsView
                } else {
                    quizView
                }
            }
        }
        .task { await vm.load() }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showHighScores) {
            HighScoreListView(
                title: "Quiz Rush — Top 10",
                accentColor: .purple,
                scores: vm.highScoreStore.topScores
            )
        }
    }

    // MARK: - Loading
    var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
            Text("Fetching questions…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Error
    func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
            Button(action: { Task { await vm.load() } }) {
                Text("Retry")
                    .font(.headline)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.purple)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
    }

    // MARK: - Quiz
    var quizView: some View {
        VStack(spacing: 24) {
            HStack {
                Text(vm.progressLabel)
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                if vm.streak > 1 {
                    Label("\(vm.streak) streak", systemImage: "flame.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.orange)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            Text("\(vm.score)")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .contentTransition(.numericText())
                .animation(.snappy, value: vm.score)

            if let question = vm.currentQuestion {
                Text(question.text)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .frame(minHeight: 90)
                    .background(flashOverlay)

                VStack(spacing: 12) {
                    ForEach(question.answers, id: \.self) { answer in
                        Button(action: { vm.selectAnswer(answer) }) {
                            Text(answer)
                                .font(.body.bold())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .foregroundStyle(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(vm.lastAnswerWasCorrect != nil)
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer()
        }
    }

    @ViewBuilder
    var flashOverlay: some View {
        if let correct = vm.lastAnswerWasCorrect {
            RoundedRectangle(cornerRadius: 14)
                .fill(correct ? Color.green.opacity(0.25) : Color.red.opacity(0.25))
                .modifier(ShakeEffect(animatableData: correct ? 0 : 1))
        }
    }

    // MARK: - Results
    var resultsView: some View {
        VStack(spacing: 20) {
            Text("Round Complete!").font(.largeTitle.bold())
            Text("Final Score").font(.headline).foregroundStyle(.secondary)
            Text("\(vm.score)")
                .font(.system(size: 72, weight: .black, design: .rounded))
                .foregroundStyle(.purple)

            if vm.isNewHighScore {
                Label("New High Score!", systemImage: "trophy.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(.yellow)
            }

            Button(action: vm.playAgain) {
                Text("Play Again")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding(.horizontal, 40)

            Button(action: { showHighScores = true }) {
                Label("High Scores", systemImage: "list.number")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = animatableData == 1 ? sin(animatableData * .pi * 6) * 6 : 0
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

#Preview { QuizRushView() }