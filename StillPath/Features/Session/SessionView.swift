import SwiftData
import SwiftUI

struct SessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let plan: SessionPlan
    @State private var index = 0
    @State private var remaining: Int?
    @State private var isPaused = false
    @State private var startedAt = Date.now

    private var stage: SessionStage { plan.stages[index] }

    var body: some View {
        ZStack {
            LinearGradient(colors: [StillPathColor.moss, StillPathColor.sage], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: StillPathSpacing.lg) {
                HStack { Button("session.finishEarly") { finish() }.foregroundStyle(.white.opacity(0.8)); Spacer(); Text("\(index + 1) / \(plan.stages.count)").foregroundStyle(.white.opacity(0.8)) }
                Spacer()
                Image(systemName: stage.kind.symbol).font(.system(size: 44)).foregroundStyle(.white.opacity(0.9))
                Text(stage.title).font(.system(.largeTitle, design: .serif, weight: .semibold)).multilineTextAlignment(.center).foregroundStyle(.white)
                if let prompt = stage.prompt { Text(prompt).font(.title3).multilineTextAlignment(.center).foregroundStyle(.white.opacity(0.88)).frame(maxWidth: 560) }
                if let remaining { Text(Duration.seconds(remaining).formatted(.time(pattern: .minuteSecond))).font(.system(size: 54, weight: .light, design: .rounded)).monospacedDigit().foregroundStyle(.white).contentTransition(.numericText()) }
                else { Text("session.noTimer").foregroundStyle(.white.opacity(0.75)) }
                Spacer()
                HStack(spacing: StillPathSpacing.md) {
                    if index > 0 { Button { move(to: index - 1) } label: { Image(systemName: "backward.fill") }.accessibilityLabel("session.previous") }
                    Button { isPaused.toggle() } label: { Image(systemName: isPaused ? "play.fill" : "pause.fill").font(.title2).padding(22).background(.white, in: Circle()).foregroundStyle(StillPathColor.moss) }.accessibilityLabel(Text(LocalizedStringKey(isPaused ? "session.continue" : "session.pause")))
                    Button { index == plan.stages.count - 1 ? finish() : move(to: index + 1) } label: { Image(systemName: index == plan.stages.count - 1 ? "checkmark" : "forward.fill") }.accessibilityLabel(Text(LocalizedStringKey(index == plan.stages.count - 1 ? "session.finish" : "session.next")))
                }.buttonStyle(.plain).foregroundStyle(.white).font(.title3)
            }.padding(StillPathSpacing.lg)
        }
        .interactiveDismissDisabled()
        .onAppear { remaining = stage.durationSeconds }
        .task(id: stage.id) {
            remaining = stage.durationSeconds
            guard remaining != nil else { return }
            while !Task.isCancelled, let value = remaining, value > 0 {
                try? await Task.sleep(for: .seconds(1)); if !isPaused { remaining = value - 1 }
            }
        }
    }

    private func move(to newIndex: Int) { if reduceMotion { index = newIndex } else { withAnimation(.easeInOut(duration: 0.35)) { index = newIndex } } }
    private func finish() { modelContext.insert(PracticeSession(routineName: plan.title, startedAt: startedAt, endedAt: .now, completedStageCount: index + 1, category: plan.stages.first?.kind ?? .custom)); dismiss() }
}
