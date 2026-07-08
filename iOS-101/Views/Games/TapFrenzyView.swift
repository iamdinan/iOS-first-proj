//
//  TapFrenzyView.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI
internal import Combine

struct TapFrenzyView: View {

    var onSessionEnd: ((GameMode, Int) -> Void)? = nil

    @State private var vm = TapFrenzyVM()
    @State private var showHighScores = false

    let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            switch vm.phase {
            case .idle:    idleView
            case .playing: playingView
            case .over:
                ResultView(
                    mode:        .tapFrenzy,
                    score:       vm.score,
                    isNewBest:   vm.isNewBest,
                    accentColor: .blue,
                    onPlayAgain:  { vm.resetGame() },
                    onShowScores: { showHighScores = true }
                )
            }
        }
        .onAppear {
            vm.onSessionEnd = { score in onSessionEnd?(.tapFrenzy, score) }
        }
        .onReceive(countdownTimer) { _ in vm.tick() }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showHighScores) {
            HighScoreListView(title: "Tap Frenzy — Top 10",
                              accentColor: .blue,
                              scores: vm.highScoreStore.topScores)
        }
    }

    var idleView: some View {
        VStack(spacing: 24) {
            Text("Tap Frenzy").font(.largeTitle.bold())
            Text("Tap as fast as you can!\nGreen = ×2 bonus · Grey = −5 penalty")
                .font(.subheadline).multilineTextAlignment(.center).foregroundStyle(.secondary)
            tapButton
        }
        .padding()
    }

    var playingView: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SCORE").font(.caption.bold()).foregroundStyle(.secondary)
                    Text("\(vm.score)")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .contentTransition(.numericText()).animation(.snappy, value: vm.score)
                }
                Spacer()
                if vm.multiplier > 1 {
                    Text("×\(vm.multiplier)")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(.orange)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 28).padding(.top, 48)
            Spacer()
            tapButton
            Spacer()
            timerBar(current: vm.timeLeft, total: 10)
                .padding(.bottom, 40)
        }
    }

    var tapButton: some View {
        Button(action: vm.handleTap) {
            Text(vm.phase == .playing ? vm.buttonColor.label : "START")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .frame(width: 200, height: 200)
                .background(vm.phase == .playing ? vm.buttonColor.color : .blue)
                .foregroundStyle(.white)
                .clipShape(Circle())
                .shadow(color: (vm.phase == .playing ? vm.buttonColor.color : Color.blue).opacity(0.4),
                        radius: 12, x: 0, y: 6)
                .scaleEffect(vm.phase == .playing ? 1.0 : 0.95)
                .animation(.spring(response: 0.15, dampingFraction: 0.5), value: vm.score)
        }
        .disabled(vm.phase == .over)
        .sensoryFeedback(.impact(weight: .medium), trigger: vm.score)
    }
}
