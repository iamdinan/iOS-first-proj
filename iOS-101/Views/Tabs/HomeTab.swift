//
//  HomeTab.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI
internal import _LocationEssentials

struct HomeTab: View {
    @Environment(LocationService.self) private var location
    @State private var statsVM = StatsVM()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Text("🎮")
                    .font(.system(size: 64))
                Text("PlayHub")
                    .font(.largeTitle.bold())
                Text("Choose a game mode")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                ForEach(GameMode.allCases, id: \.self) { mode in
                    NavigationLink(destination: destination(for: mode)) {
                        GameModeButton(mode: mode)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationBarHidden(true)
        }
    }

    @ViewBuilder
    private func destination(for mode: GameMode) -> some View {
        switch mode {
        case .tapFrenzy: TapFrenzyView(onSessionEnd: saveSession)
        case .lightItUp: LightItUpView(onSessionEnd: saveSession)
        case .quizRush:  QuizRushView(onSessionEnd: saveSession)
        }
    }

    private func saveSession(mode: GameMode, score: Int) {
        let lat = location.lastLocation?.coordinate.latitude  ?? 0
        let lon = location.lastLocation?.coordinate.longitude ?? 0
        let session = GameSession(mode: mode, score: score,
                                  latitude: lat, longitude: lon)
        SessionStore.shared.append(session)
        statsVM.load()
    }
}
