//
//  MapTab.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI
import MapKit

struct MapTab: View {
    @State private var sessions: [GameSession] = []
    @State private var selected: GameSession?  = nil

    var body: some View {
        NavigationStack {
            Map(selection: $selected) {
                ForEach(sessions.filter { $0.latitude != 0 }) { session in
                    Marker(session.mode.rawValue,
                           systemImage: session.mode.icon,
                           coordinate: CLLocationCoordinate2D(
                               latitude:  session.latitude,
                               longitude: session.longitude))
                    .tag(session)
                }
            }
            .navigationTitle("Game Map")
            .onAppear {
                sessions = SessionStore.shared.load()
            }
            .sheet(item: $selected) { session in
                SessionDetailSheet(session: session)
                    .presentationDetents([.fraction(0.35)])
            }
        }
    }
}

private struct SessionDetailSheet: View {
    let session: GameSession

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: session.mode.icon)
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text(session.mode.rawValue)
                .font(.title2.bold())
            Text("Score: \(session.score)")
                .font(.title.bold())
            Text(session.timestamp, style: .date)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            ScoreBadge(mode: session.mode, score: session.score)

        }
        .padding(.top, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
