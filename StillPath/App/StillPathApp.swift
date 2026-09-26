import SwiftData
import SwiftUI

@main
struct StillPathApp: App {
    private let container: ModelContainer
    @State private var appState: AppState

    init() {
        do {
            let schema = Schema([PracticeRoutine.self, PracticeBlock.self, JournalEntry.self, PracticeSession.self, ReminderSchedule.self])
            container = try ModelContainer(for: schema)
        } catch {
            fatalError("Unable to create StillPath's local store: \(error.localizedDescription)")
        }
        _appState = State(initialValue: AppState())
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(appState)
                .environment(EntitlementStore())
                .environment(PrivacySettings())
        }
        .modelContainer(container)
    }
}

