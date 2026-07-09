//
//  PlayHubApp.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI

@main
struct PlayHubApp: App {
    @State private var locationService = LocationService()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RootTabView()
            }
            .environment(locationService)
            .task { locationService.requestPermission() }
        }
    }
}
