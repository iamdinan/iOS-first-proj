//
//  QuizRushView.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI

struct QuizRushView: View {

    var onSessionEnd: ((GameMode, Int) -> Void)? = nil

    @StateObject private var vm = QuizRushVM()
    @State private var showHighScores = false
    @State private var showExitConfirm = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            switch vm.state {
            case .loading:         loadingView
            case .failed(let msg): errorView(msg)
            case .loaded:
                if vm.isRoundComplete {
                    ResultView(
                        mode:        .quizRush,
                        score:       vm.score,
                        isNewBest:   vm.isNewBest,
                        accentColor: .purple,
                        onPlayAgain:  { vm.playAgain() },
                        onShowScores: { showHighScores = true }
                    )
                } else {
                    quizView
                }
            }
        }
        .onAppear {
            vm.onSessionEnd = { score in onSessionEnd?(.quizRush, score) }
        }
        .task { await vm.load() }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showHighScores) {
            HighScoreListView(title: "Quiz Rush — Top 10",
                              accentColor: .purple,
                              scores: vm.highScoreStore.topScores)
        }
        .navigationBarBackButtonHidden(isQuizActive)
                .toolbar {
                    if isQuizActive {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Quit") { showExitConfirm = true }
                        }
                    }
                }
                .alert("Quit game?", isPresented: $showExitConfirm) {
                    Button("Quit", role: .destructive) { dismiss() }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Your current progress will be lost.")
                }
                .disableSwipeBack(isQuizActive)
    }
    
    private var isQuizActive: Bool {
            if case .loaded = vm.state { return !vm.isRoundComplete }
            return false
        }

    var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().scaleEffect(1.4)
            Text("Fetching questions…").font(.subheadline).foregroundStyle(.secondary)
        }
    }

    func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash").font(.system(size: 44)).foregroundStyle(.secondary)
            Text(message)
                .font(.subheadline).multilineTextAlignment(.center)
                .foregroundStyle(.secondary).padding(.horizontal, 32)
            Button(action: { Task { await vm.load() } }) {
                Text("Retry")
                    .font(.headline).padding(.horizontal, 32).padding(.vertical, 12)
                    .background(Color.purple).foregroundStyle(.white).clipShape(Capsule())
            }
        }
    }

    var quizView: some View {
        VStack(spacing: 24) {
            HStack {
                Text(vm.progressLabel).font(.subheadline.bold()).foregroundStyle(.secondary)
                Spacer()
                if vm.streak > 1 {
                    Label("\(vm.streak) streak", systemImage: "flame.fill")
                        .font(.subheadline.bold()).foregroundStyle(.orange)
                }
            }
            .padding(.horizontal, 24).padding(.top, 24)

            Text("\(vm.score)")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .contentTransition(.numericText()).animation(.snappy, value: vm.score)

            if let question = vm.currentQuestion {
                Text(question.text)
                    .font(.title3.bold()).multilineTextAlignment(.center)
                    .padding(.horizontal, 24).frame(minHeight: 90)
                    .background(flashBackground)

                VStack(spacing: 12) {
                    ForEach(question.answers, id: \.self) { answer in
                        Button(action: { vm.selectAnswer(answer) }) {
                            Text(answer)
                                .font(.body.bold()).frame(maxWidth: .infinity).padding()
                                .background(buttonBackground(for: answer))
                                .foregroundStyle(buttonForeground(for: answer))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .animation(.easeInOut(duration: 0.2),
                                           value: vm.revealedCorrectAnswer)
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
    var flashBackground: some View {
        if let correct = vm.lastAnswerWasCorrect {
            RoundedRectangle(cornerRadius: 14)
                .fill(correct ? Color.green.opacity(0.25) : Color.red.opacity(0.25))
                .modifier(ShakeEffect(animatableData: correct ? 0 : 1))
        }
    }

    func buttonBackground(for answer: String) -> Color {
        if let correct = vm.revealedCorrectAnswer {
            return answer == correct ? .green : Color(.systemGray6)
        }
        return Color(.systemGray6)
    }

    func buttonForeground(for answer: String) -> Color {
        if let correct = vm.revealedCorrectAnswer {
            return answer == correct ? .white : Color(.systemGray3)
        }
        return .primary
    }
}

struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    func effectValue(size: CGSize) -> ProjectionTransform {
        let t = animatableData == 1 ? sin(animatableData * .pi * 6) * 6 : 0
        return ProjectionTransform(CGAffineTransform(translationX: t, y: 0))
    }
}
