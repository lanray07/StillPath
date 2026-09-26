import Foundation
import SwiftData

@Model final class JournalEntry {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var modifiedAt: Date
    var title: String
    var body: String
    var isFavourite: Bool
    var tags: [String]
    var audioFileName: String?
    var transcription: String?
    var translatedBody: String?
    var translationLanguage: String?
    var linkedPracticeName: String?

    init(title: String = "", body: String = "", tags: [String] = []) {
        id = UUID(); createdAt = .now; modifiedAt = .now; self.title = title; self.body = body; isFavourite = false; self.tags = tags
    }
}

@Model final class ReminderSchedule {
    @Attribute(.unique) var id: UUID
    var hour: Int
    var minute: Int
    var weekdayValues: [Int]
    var message: String
    var isEnabled: Bool
    var pausedUntil: Date?
    init(hour: Int = 8, minute: Int = 0, weekdays: [Int] = Array(1...7), message: String) {
        id = UUID(); self.hour = hour; self.minute = minute; weekdayValues = weekdays; self.message = message; isEnabled = true
    }
}
