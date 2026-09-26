import SwiftUI

struct OnboardingFlow: View {
    @Environment(AppState.self) private var appState
    @State private var page = 0
    @State private var intentions: Set<PracticeKind> = []
    @State private var traditions: Set<FaithTradition> = []
    @State private var minutes = 5

    var body: some View {
        ZStack {
            CalmBackground()
            VStack(spacing: StillPathSpacing.lg) {
                HStack { Spacer(); if page > 0 { Button("common.back") { withAnimation { page -= 1 } } } }.frame(height: 32)
                Group {
                    switch page {
                    case 0: welcome
                    case 1: intention
                    case 2: tradition
                    default: time
                    }
                }.frame(maxWidth: 680, maxHeight: .infinity)
                Button(LocalizedStringKey(page == 0 ? "onboarding.begin" : page == 3 ? "onboarding.finish" : "common.continue")) {
                    if page == 3 { appState.hasCompletedOnboarding = true } else { withAnimation(.easeInOut) { page += 1 } }
                }.buttonStyle(PrimaryButtonStyle()).frame(maxWidth: 560)
                Text("onboarding.progress \(page + 1) 4").font(.caption).foregroundStyle(.secondary).accessibilityLabel("Step \(page + 1) of 4")
            }.padding(StillPathSpacing.lg)
        }
    }

    private var welcome: some View {
        VStack(spacing: StillPathSpacing.md) {
            Image(systemName: "circle.hexagongrid.fill").font(.system(size: 72)).foregroundStyle(StillPathColor.sage)
            Text("onboarding.welcome.title").font(.system(.largeTitle, design: .serif, weight: .semibold)).multilineTextAlignment(.center)
            Text("onboarding.welcome.body").font(.title3).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
    }

    private var intention: some View {
        SelectionPage(title: "onboarding.intention.title", subtitle: "onboarding.selectMany") {
            FlowLayout { ForEach(PracticeKind.allCases) { kind in SelectableChip(title: LocalizedStringKey("practice.\(kind.rawValue)"), selected: intentions.contains(kind)) { toggle(kind, in: &intentions) } } }
        }
    }

    private var tradition: some View {
        SelectionPage(title: "onboarding.tradition.title", subtitle: "onboarding.tradition.body") {
            ScrollView { FlowLayout { ForEach(FaithTradition.allCases) { item in SelectableChip(title: LocalizedStringKey("tradition.\(item.rawValue)"), selected: traditions.contains(item)) { toggle(item, in: &traditions) } } } }
        }
    }

    private var time: some View {
        SelectionPage(title: "onboarding.time.title", subtitle: "onboarding.time.body") {
            Picker("onboarding.time.title", selection: $minutes) { ForEach([2, 5, 10, 15, 20], id: \.self) { Text("duration.minutes \($0)").tag($0) } }.pickerStyle(.wheel)
        }
    }

    private func toggle<T: Hashable>(_ item: T, in selection: inout Set<T>) { if selection.contains(item) { selection.remove(item) } else { selection.insert(item) } }
}

private struct SelectionPage<Content: View>: View {
    let title: LocalizedStringKey; let subtitle: LocalizedStringKey; @ViewBuilder let content: Content
    var body: some View { VStack(spacing: StillPathSpacing.md) { Text(title).font(.system(.largeTitle, design: .serif, weight: .semibold)).multilineTextAlignment(.center); Text(subtitle).foregroundStyle(.secondary).multilineTextAlignment(.center); content }.frame(maxWidth: .infinity) }
}

private struct SelectableChip: View {
    let title: LocalizedStringKey; let selected: Bool; let action: () -> Void
    var body: some View { Button(action: action) { Text(title).padding(.horizontal, 16).padding(.vertical, 12).background(selected ? StillPathColor.sage : Color(.secondarySystemBackground), in: Capsule()).foregroundStyle(selected ? .white : .primary) }.buttonStyle(.plain) }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat = 10
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize { layout(proposal: proposal, subviews: subviews).size }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) { let result = layout(proposal: proposal, subviews: subviews); for (index, point) in result.points.enumerated() { subviews[index].place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), proposal: .unspecified) } }
    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, points: [CGPoint]) { let width = proposal.width ?? 600; var x: CGFloat = 0; var y: CGFloat = 0; var row: CGFloat = 0; var points: [CGPoint] = []; for view in subviews { let size = view.sizeThatFits(.unspecified); if x + size.width > width, x > 0 { x = 0; y += row + spacing; row = 0 }; points.append(CGPoint(x: x, y: y)); x += size.width + spacing; row = max(row, size.height) }; return (CGSize(width: width, height: y + row), points) }
}
