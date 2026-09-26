import Observation
import SwiftUI

@MainActor @Observable
final class AppState {
    var selectedTab: AppTab = .home
    var activeSession: SessionPlan?
    var presentedSheet: SheetDestination?

    @ObservationIgnored @AppStorage("onboarding.complete") var hasCompletedOnboarding = false
    @ObservationIgnored @AppStorage("preferred.language") var preferredLanguage = "system"
}

enum AppTab: String, CaseIterable, Identifiable {
    case home, practices, journal, journey, settings
    var id: Self { self }
    var title: LocalizedStringKey { LocalizedStringKey("tab.\(rawValue)") }
    var symbol: String {
        switch self {
        case .home: "house"
        case .practices: "circle.grid.cross"
        case .journal: "book.closed"
        case .journey: "calendar"
        case .settings: "gearshape"
        }
    }
}

enum SheetDestination: Identifiable {
    case newRoutine, newJournal, paywall
    var id: String {
        switch self { case .newRoutine: "newRoutine"; case .newJournal: "newJournal"; case .paywall: "paywall" }
    }
}

