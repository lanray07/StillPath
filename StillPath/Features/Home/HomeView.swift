import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    private var greeting: LocalizedStringKey {
        switch Calendar.current.component(.hour, from: .now) { case 5..<12: "home.morning"; case 12..<18: "home.afternoon"; default: "home.evening" }
    }

    var body: some View {
        ZStack {
            CalmBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: StillPathSpacing.lg) {
                    VStack(alignment: .leading, spacing: StillPathSpacing.xs) {
                        Text(greeting).font(.system(.largeTitle, design: .serif, weight: .semibold))
                        Text("home.subtitle").foregroundStyle(.secondary)
                    }
                    StillPathCard {
                        VStack(alignment: .leading, spacing: StillPathSpacing.md) {
                            Label("home.today", systemImage: "sun.max").font(.subheadline.weight(.semibold)).foregroundStyle(StillPathColor.sage)
                            Text("home.grounding").font(.system(.title2, design: .serif, weight: .semibold))
                            HStack { StagePill(icon: "sparkles", minutes: 1); StagePill(icon: "text.book.closed", minutes: 2); StagePill(icon: "hands.sparkles", minutes: 2) }
                            Button("home.begin") { appState.activeSession = .morningGrounding }.buttonStyle(PrimaryButtonStyle()).accessibilityHint("Begins a five minute practice")
                        }
                    }
                    HStack(spacing: StillPathSpacing.sm) {
                        QuietAction(title: "home.quietMoment", icon: "moon.stars") { appState.activeSession = .quietMoment }
                        QuietAction(title: "home.quickReflection", icon: "square.and.pencil") { appState.presentedSheet = .newJournal }
                    }
                    StillPathCard {
                        VStack(alignment: .leading, spacing: StillPathSpacing.sm) {
                            Text("home.prompt.label").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                            Text("reflection.prompt.attention").font(.system(.title3, design: .serif))
                            Button("home.reflect") { appState.presentedSheet = .newJournal }
                        }
                    }
                }.padding(StillPathSpacing.md)
            }
        }.navigationTitle("StillPath").navigationBarTitleDisplayMode(.inline)
    }
}

private struct StagePill: View {
    let icon: String; let minutes: Int
    var body: some View { Label { Text("duration.minutes \(minutes)") } icon: { Image(systemName: icon) }.font(.caption).padding(.horizontal, 10).padding(.vertical, 7).background(StillPathColor.mist, in: Capsule()) }
}

private struct QuietAction: View {
    let title: LocalizedStringKey; let icon: String; let action: () -> Void
    var body: some View { Button(action: action) { VStack(alignment: .leading, spacing: StillPathSpacing.sm) { Image(systemName: icon).font(.title2); Text(title).font(.headline) }.frame(maxWidth: .infinity, minHeight: 94, alignment: .leading).padding().background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: StillPathRadius.card)) }.buttonStyle(.plain) }
}

extension SessionPlan {
    static let morningGrounding = SessionPlan(title: String(localized: "home.grounding"), stages: [
        SessionStage(kind: .stillness, title: String(localized: "practice.stillness"), prompt: String(localized: "session.stillness.prompt"), durationSeconds: 60),
        SessionStage(kind: .reading, title: String(localized: "practice.reading"), prompt: String(localized: "session.reading.placeholder"), durationSeconds: 120),
        SessionStage(kind: .prayer, title: String(localized: "practice.prayer"), prompt: String(localized: "session.prayer.prompt"), durationSeconds: 120),
        SessionStage(kind: .reflection, title: String(localized: "practice.reflection"), prompt: String(localized: "reflection.prompt.stayed"), durationSeconds: nil)
    ])
    static let quietMoment = SessionPlan(title: String(localized: "home.quietMoment"), stages: [SessionStage(kind: .stillness, title: String(localized: "practice.stillness"), prompt: String(localized: "session.stillness.prompt"), durationSeconds: nil)])
}

