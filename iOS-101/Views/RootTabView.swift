//
//  RootTabView.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeTab()
                .tabItem { Label("Home",     systemImage: "gamecontroller.fill") }

            StatsTab()
                .tabItem { Label("Stats",    systemImage: "chart.bar.fill") }

            MapTab()
                .tabItem { Label("Map",      systemImage: "map.fill") }

            SettingsTab()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}

#Preview {
    RootTabView()
        .environment(LocationService())
}
