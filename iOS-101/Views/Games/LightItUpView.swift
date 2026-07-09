//
//  LightItUpView.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI
internal import Combine

struct LightItUpView: View {

    var onSessionEnd: ((GameMode, Int) -> Void)? = nil

    @State private var vm = LightItUpVM()
    @State private var showHighScores = false

    let roundTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            switch vm.phase {
            case .idle:    idleView
            case .playing: playingView
            case .over:
                ResultView(
                    mode:        .lightItUp,
                    score:       vm.score,
                    isNewBest:   vm.isNewBest,
                    accentColor: .indigo,
                    onPlayAgain:  { vm.resetGame() },
                    onShowScores: { showHighScores = true }
                )
            }
            if vm.showLevelFlash {
                Color.white.opacity(0.35).ignoresSafeArea().allowsHitTesting(false)
                Text("LEVEL \(vm.level.number)")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(vm.level.glowColor)
                    .shadow(color: vm.level.glowColor, radius: 16)
                    .allowsHitTesting(false)
            }
            if vm.showLifeLostFlash {
                Theme.neonRed.opacity(0.25).ignoresSafeArea().allowsHitTesting(false)
            }
        }
        .onAppear {
            vm.onSessionEnd = { score in onSessionEnd?(.lightItUp, score) }
        }
        .onReceive(roundTimer) { _ in vm.tick() }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showHighScores) {
            HighScoreListView(title: "Light It Up — Top 10",
                              accentColor: .indigo,
                              scores: vm.highScoreStore.topScores)
        }
    }

    var idleView: some View {
        VStack(spacing: 24) {
            Text("Light It Up").font(.largeTitle.bold())
            Text("Tap the glowing card before it goes dark.\nMiss or tap wrong — lose points.")
                .font(.subheadline).multilineTextAlignment(.center).foregroundStyle(.secondary)
            startButton
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
                VStack(alignment: .trailing, spacing: 2) {
                    Text("LEVEL").font(.caption.bold()).foregroundStyle(.secondary)
                    Text("\(vm.level.number)")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(vm.level.glowColor)
                    livesView
                }
            }
            .padding(.horizontal, 28).padding(.top, 48)
            Spacer()
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12),
                               count: vm.level.columns), spacing: 12
            ) {
                ForEach(vm.cards) { card in
                    CardView(card: card, glowColor: vm.level.glowColor)
                        .onTapGesture { vm.handleCardTap(card) }
                }
            }
            .padding(.horizontal, 28)
            .animation(.easeInOut(duration: 0.25), value: vm.cards.map(\.id))
            Spacer()
            timerBar(current: vm.timeLeft, total: 60).padding(.bottom, 40)
        }
    }

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
    
    var livesView: some View {
        HStack(spacing: 4) {
            ForEach(0..<vm.maxLives, id: \.self) { i in
                Image(systemName: i < vm.lives ? "heart.fill" : "heart")
                    .font(.system(size: 16))
                    .foregroundStyle(i < vm.lives ? Theme.neonRed : Theme.textSecondary.opacity(0.3))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: vm.lives)
    }
}
