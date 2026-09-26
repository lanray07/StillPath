import SwiftUI

struct AppRootView: View {
    @Environment(AppState.self) private var appState
    @Environment(PrivacySettings.self) private var privacy
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        @Bindable var state = appState
        Group {
            if !state.hasCompletedOnboarding {
                OnboardingFlow()
            } else if privacy.isLocked {
                AppLockView()
            } else {
                tabShell
                    .fullScreenCover(item: $state.activeSession) { SessionView(plan: $0) }
                    .sheet(item: $state.presentedSheet) { destination in
                        switch destination {
                        case .newRoutine: NavigationStack { RoutineEditorView() }
                        case .newJournal: NavigationStack { JournalEditorView() }
                        case .paywall: NavigationStack { PaywallView() }
                        }
                    }
            }
        }
        .tint(StillPathColor.sage)
        .onAppear { consumePendingIntent() }
        .onOpenURL { url in
            guard url.scheme == "stillpath" else { return }
            if url.host == "journal" { appState.selectedTab = .journal; appState.presentedSheet = .newJournal }
            if url.host == "practice" {
                switch url.pathComponents.dropFirst().first {
                case "prayer": appState.activeSession = SessionPlan(title: String(localized: "practice.prayer"), stages: [SessionStage(kind: .prayer, title: String(localized: "practice.prayer"), prompt: String(localized: "session.prayer.prompt"), durationSeconds: nil)])
                case "meditation": appState.activeSession = SessionPlan(title: String(localized: "practice.meditation"), stages: [SessionStage(kind: .meditation, title: String(localized: "practice.meditation"), prompt: String(localized: "session.stillness.prompt"), durationSeconds: 300)])
                case "reflection": appState.presentedSheet = .newJournal
                default: appState.activeSession = .morningGrounding
                }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { consumePendingIntent() }
            if phase != .active, privacy.requireBiometrics { privacy.lock() }
        }
    }

    private var tabShell: some View {
        @Bindable var state = appState
        return TabView(selection: $state.selectedTab) {
            NavigationStack { HomeView() }.tabItem { Label(AppTab.home.title, systemImage: AppTab.home.symbol) }.tag(AppTab.home)
            NavigationStack { PracticesView() }.tabItem { Label(AppTab.practices.title, systemImage: AppTab.practices.symbol) }.tag(AppTab.practices)
            NavigationStack { JournalView() }.tabItem { Label(AppTab.journal.title, systemImage: AppTab.journal.symbol) }.tag(AppTab.journal)
            NavigationStack { JourneyView() }.tabItem { Label(AppTab.journey.title, systemImage: AppTab.journey.symbol) }.tag(AppTab.journey)
            NavigationStack { SettingsView() }.tabItem { Label(AppTab.settings.title, systemImage: AppTab.settings.symbol) }.tag(AppTab.settings)
        }
    }

    private func consumePendingIntent() {
        guard let destination = UserDefaults.standard.string(forKey: "intent.pendingDestination") else { return }
        UserDefaults.standard.removeObject(forKey: "intent.pendingDestination")
        if destination == "journal" { appState.selectedTab = .journal; appState.presentedSheet = .newJournal; return }
        guard destination.hasPrefix("practice/") else { return }
        switch destination.split(separator: "/").last {
        case "prayer": appState.activeSession = SessionPlan(title: String(localized: "practice.prayer"), stages: [SessionStage(kind: .prayer, title: String(localized: "practice.prayer"), prompt: String(localized: "session.prayer.prompt"), durationSeconds: nil)])
        case "meditation": appState.activeSession = SessionPlan(title: String(localized: "practice.meditation"), stages: [SessionStage(kind: .meditation, title: String(localized: "practice.meditation"), prompt: String(localized: "session.stillness.prompt"), durationSeconds: 300)])
        case "reflection": appState.presentedSheet = .newJournal
        default: appState.activeSession = .morningGrounding
        }
    }
}

