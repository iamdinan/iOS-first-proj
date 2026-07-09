//
//  SettingsTab.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI

struct SettingsTab: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("challengeHour")        private var challengeHour        = 9
    @AppStorage("challengeMinute")      private var challengeMinute      = 0
    @State private var statsVM = StatsVM()
    @State private var showResetConfirm = false

    @State private var permissionGranted = false

    // Date used only to drive the time picker UI
    private var challengeTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    bySettingHour: challengeHour, minute: challengeMinute, second: 0,
                    of: Date()) ?? Date()
            },
            set: { newDate in
                let comps     = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                challengeHour   = comps.hour   ?? 9
                challengeMinute = comps.minute ?? 0
                if notificationsEnabled { reschedule() }
            }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Challenge") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, enabled in
                            if enabled { requestAndSchedule() } else {
                                NotificationService.shared.cancelAll()
                            }
                        }

                    if notificationsEnabled && permissionGranted {
                        DatePicker("Challenge Time",
                                   selection: challengeTime,
                                   displayedComponents: .hourAndMinute)
                    }

                    if notificationsEnabled && !permissionGranted {
                        Text("Enable notifications in Settings → PlayHub to receive daily challenges.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Modes",   value: "3")
                }
                
                Section {
                    Button("Reset All Stats", role: .destructive) {
                        showResetConfirm = true
                    }
                } footer: {
                    Text("Clears all game sessions, scores, and map history. This cannot be undone.")
                }
            }
            .navigationTitle("Settings")
            .task { await checkPermission() }
            .confirmationDialog("Reset all stats?",
                                isPresented: $showResetConfirm,
                                titleVisibility: .visible) {
                Button("Reset Everything", role: .destructive) { statsVM.deleteAll() }
            } message: {
                Text("This cannot be undone.")
            }
        }
    }

    private func requestAndSchedule() {
        Task {
            permissionGranted = await NotificationService.shared.requestPermission()
            if permissionGranted { reschedule() } else { notificationsEnabled = false }
        }
    }

    private func reschedule() {
        NotificationService.shared.schedule(at: challengeHour, minute: challengeMinute)
    }

    private func checkPermission() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        permissionGranted = settings.authorizationStatus == .authorized
    }
}
