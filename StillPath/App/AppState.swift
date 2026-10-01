import Foundation
import Observation
import SwiftUI

@MainActor @Observable
final class AppState {
    @ObservationIgnored private let defaults: UserDefaults

    var selectedTab: AppTab = .home
    var activeSession: SessionPlan?
    var presentedSheet: SheetDestination?

    var hasCompletedOnboarding: Bool {
        didSet { defaults.set(hasCompletedOnboarding, forKey: "onboarding.complete") }
    }

    var preferredLanguage: String {
        didSet { defaults.set(preferredLanguage, forKey: "preferred.language") }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasCompletedOnboarding = defaults.bool(forKey: "onboarding.complete")
        preferredLanguage = defaults.string(forKey: "preferred.language") ?? "system"
    }
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

