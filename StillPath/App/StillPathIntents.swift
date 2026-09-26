import AppIntents
import Foundation

struct StartPracticeIntent: AppIntent {
    static let title: LocalizedStringResource = "intent.startPractice.title"
    static let description = IntentDescription("intent.startPractice.description")
    static let openAppWhenRun = true
    @Parameter(title: "intent.practiceKind") var kind: IntentPracticeKind
    static var parameterSummary: some ParameterSummary { Summary("Start \(\.$kind)") }
    func perform() async throws -> some IntentResult {
        UserDefaults.standard.set("practice/\(kind.rawValue)", forKey: "intent.pendingDestination")
        return .result()
    }
}

enum IntentPracticeKind: String, AppEnum {
    case daily, prayer, meditation, reflection
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "intent.practiceKind"
    static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [.daily: "intent.daily", .prayer: "intent.prayer", .meditation: "intent.meditation", .reflection: "intent.reflection"]
}

struct OpenJournalIntent: AppIntent {
    static let title: LocalizedStringResource = "intent.openJournal.title"
    static let openAppWhenRun = true
    func perform() async throws -> some IntentResult {
        UserDefaults.standard.set("journal", forKey: "intent.pendingDestination")
        return .result()
    }
}

struct StillPathShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: StartPracticeIntent(), phrases: ["Start a practice in \(.applicationName)", "Start prayer in \(.applicationName)", "Start meditation in \(.applicationName)"], shortTitle: "intent.startPractice.title", systemImageName: "circle.hexagongrid")
        AppShortcut(intent: OpenJournalIntent(), phrases: ["Open my journal in \(.applicationName)", "Record a reflection in \(.applicationName)"], shortTitle: "intent.openJournal.title", systemImageName: "book.closed")
    }
}

