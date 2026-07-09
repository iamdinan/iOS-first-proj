//
//  RootTabView.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI

struct RootTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.surface)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            HomeTab().tabItem { Label("Home", systemImage: "gamecontroller.fill") }
            StatsTab().tabItem { Label("Stats", systemImage: "chart.bar.fill") }
            MapTab().tabItem { Label("Map", systemImage: "map.fill") }
            SettingsTab().tabItem { Label("Settings", systemImage: "gear") }
        }
        .tint(Theme.neonGreen)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    RootTabView()
        .environment(LocationService())
}
