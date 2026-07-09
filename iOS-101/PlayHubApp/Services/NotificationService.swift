//
//  NotificationService.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import UserNotifications

struct NotificationService {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()
    private let identifier = "dailyChallenge"

    private init() {}

    func requestPermission() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    func schedule(at hour: Int, minute: Int) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge 🎮"
        content.body  = "Your daily PlayHub challenge is ready. Can you beat your best?"
        content.sound = .default

        var components        = DateComponents()
        components.hour       = hour
        components.minute     = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)
        center.add(request)
    }

    func cancelAll() {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }
}
