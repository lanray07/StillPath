import Foundation
import UserNotifications

protocol ReminderScheduling: Sendable {
    func requestAuthorization() async throws -> Bool
    func schedule(_ reminder: ReminderRequest) async throws
    func cancel(id: UUID)
}

struct ReminderRequest: Sendable {
    let id: UUID
    let hour: Int
    let minute: Int
    let weekdays: [Int]
    let message: String
    let isEnabled: Bool
    let pausedUntil: Date?
}

struct ReminderService: ReminderScheduling {
    func requestAuthorization() async throws -> Bool { try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) }

    func schedule(_ reminder: ReminderRequest) async throws {
        cancel(id: reminder.id)
        guard reminder.isEnabled, reminder.pausedUntil.map({ $0 < .now }) ?? true else { return }
        for weekday in reminder.weekdays {
            var components = DateComponents(); components.calendar = .autoupdatingCurrent; components.timeZone = .autoupdatingCurrent
            components.weekday = weekday; components.hour = reminder.hour; components.minute = reminder.minute
            let content = UNMutableNotificationContent(); content.title = "StillPath"; content.body = reminder.message; content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            try await UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "\(reminder.id)-\(weekday)", content: content, trigger: trigger))
        }
    }

    func cancel(id: UUID) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let ids = requests.map(\.identifier).filter { $0.hasPrefix(id.uuidString) }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
}

