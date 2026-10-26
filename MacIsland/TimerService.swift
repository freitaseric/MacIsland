//
//  TimerService.swift
//  MacIsland
//
//  A small, permission-free integration: a focus timer that lives in the
//  island alongside Spotify. It keeps running when the user switches back to
//  Spotify and sends a local notification when it finishes.
//

import Combine
import Foundation
import UserNotifications

@MainActor
final class TimerService: ObservableObject {
    struct Preset: Identifiable, Equatable {
        let minutes: Int

        var id: Int { minutes }
        var seconds: TimeInterval { TimeInterval(minutes * 60) }
    }

    static let presets: [Preset] = [
        Preset(minutes: 5),
        Preset(minutes: 15),
        Preset(minutes: 25),
    ]

    @Published private(set) var duration: TimeInterval = 25 * 60
    @Published private(set) var remaining: TimeInterval = 25 * 60
    @Published private(set) var isRunning = false
    @Published private(set) var isFinished = false

    private var endDate: Date?
    private var tickTask: Task<Void, Never>?
    private var hasRequestedNotifications = false
    private let notificationDelegate = TimerNotificationDelegate()

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var selectedMinutes: Int {
        max(1, Int(duration / 60))
    }

    var elapsedFraction: Double {
        guard duration > 0 else { return 0 }
        return min(max(1 - remaining / duration, 0), 1)
    }

    func select(_ preset: Preset) {
        guard !isRunning else { return }
        duration = preset.seconds
        remaining = preset.seconds
        isFinished = false
    }

    func toggle() {
        if isRunning {
            pause()
        } else {
            start()
        }
    }

    func start() {
        if remaining <= 0 || isFinished {
            remaining = duration
            isFinished = false
        }

        endDate = Date().addingTimeInterval(remaining)
        isRunning = true

        ensureNotificationPermission()
        startTicking()
    }

    func pause() {
        guard isRunning else { return }

        if let endDate {
            remaining = max(0, endDate.timeIntervalSinceNow)
        }

        isRunning = false
        endDate = nil
        tickTask?.cancel()
        tickTask = nil
    }

    func reset() {
        tickTask?.cancel()
        tickTask = nil
        endDate = nil
        isRunning = false
        isFinished = false
        remaining = duration
    }

    func stop() {
        tickTask?.cancel()
        tickTask = nil
        endDate = nil
        isRunning = false
    }

    private func startTicking() {
        tickTask?.cancel()

        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(250))

                guard let self, let endDate = self.endDate else {
                    return
                }

                let newRemaining = endDate.timeIntervalSinceNow
                if newRemaining <= 0 {
                    self.finish()
                    return
                }

                self.remaining = newRemaining
            }
        }
    }

    private func finish() {
        remaining = 0
        isRunning = false
        isFinished = true
        endDate = nil
        tickTask?.cancel()
        tickTask = nil
        sendNotification()
    }

    private func ensureNotificationPermission() {
        guard !hasRequestedNotifications else { return }
        hasRequestedNotifications = true

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound]
        ) { _, _ in }
    }

    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = L10n.timerNotificationTitle
        content.body = String(
            format: L10n.timerNotificationBodyFormat,
            selectedMinutes
        )
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}

private nonisolated final class TimerNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
