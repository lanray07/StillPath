import SwiftData
import SwiftUI

struct PracticesView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PracticeRoutine.createdAt) private var routines: [PracticeRoutine]
    var body: some View {
        ZStack {
            CalmBackground()
            Group {
                if routines.filter({ !$0.isArchived }).isEmpty { ContentUnavailableView("practices.empty.title", systemImage: "circle.grid.cross", description: Text("practices.empty.body")) }
                else {
                    List {
                        ForEach(routines.filter { !$0.isArchived }) { routine in
                            RoutineRow(routine: routine) { appState.activeSession = routine.sessionPlan }
                                .swipeActions {
                                    Button("routine.archive") { routine.isArchived = true }.tint(StillPathColor.sage)
                                    Button("routine.duplicate") { duplicate(routine) }.tint(StillPathColor.clay)
                                    Button("common.delete", role: .destructive) { modelContext.delete(routine) }
                                }
                                .listRowBackground(Color.clear)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle("practices.title")
        .toolbar { Button { appState.presentedSheet = .newRoutine } label: { Label("practices.new", systemImage: "plus") } }
    }

    private func duplicate(_ source: PracticeRoutine) {
        let copy = PracticeRoutine(name: String(localized: "routine.copyName \(source.name)"))
        copy.blocks = source.blocks.map { PracticeBlock(kind: $0.kind, title: $0.title, durationSeconds: $0.durationSeconds, prompt: $0.prompt, sortOrder: $0.sortOrder, isOptional: $0.isOptional) }
        modelContext.insert(copy)
    }
}

private struct RoutineRow: View {
    let routine: PracticeRoutine; let begin: () -> Void
    var body: some View {
        StillPathCard { VStack(alignment: .leading, spacing: StillPathSpacing.sm) { Text(routine.name).font(.title3.bold()); Text("routine.summary \(routine.blocks.count) \(max(1, routine.totalSeconds / 60))").foregroundStyle(.secondary); HStack { ForEach(routine.blocks.sorted(by: { $0.sortOrder < $1.sortOrder }).prefix(4)) { Image(systemName: $0.kind.symbol).foregroundStyle(StillPathColor.sage) }; Spacer(); Button("home.begin", action: begin).buttonStyle(.borderedProminent) } } }
    }
}

private extension PracticeRoutine {
    var sessionPlan: SessionPlan { SessionPlan(title: name, stages: blocks.sorted(by: { $0.sortOrder < $1.sortOrder }).map { SessionStage(kind: $0.kind, title: $0.title, prompt: $0.prompt, durationSeconds: $0.durationSeconds) }) }
}

struct RoutineEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name = ""
    @State private var selected: [PracticeKind] = [.stillness, .reflection]
    @State private var minutes = 2

    var body: some View {
        Form {
            Section("routine.name") { TextField("routine.name.placeholder", text: $name) }
            Section("routine.blocks") {
                ForEach(selected, id: \.self) { kind in Label(LocalizedStringKey("practice.\(kind.rawValue)"), systemImage: kind.symbol) }
                    .onMove { selected.move(fromOffsets: $0, toOffset: $1) }.onDelete { selected.remove(atOffsets: $0) }
                Menu("routine.addBlock") { ForEach(PracticeKind.allCases.filter { !selected.contains($0) }) { kind in Button(LocalizedStringKey("practice.\(kind.rawValue)")) { selected.append(kind) } } }
            }
            Section("routine.duration") { Stepper("routine.durationMinutes \(minutes)", value: $minutes, in: 1...60) }
        }.navigationTitle("practices.new").toolbar { ToolbarItem(placement: .cancellationAction) { Button("common.cancel") { dismiss() } }; ToolbarItem(placement: .confirmationAction) { Button("common.save") { save() }.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selected.isEmpty) } }
    }

    private func save() {
        let routine = PracticeRoutine(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
        routine.blocks = selected.enumerated().map { index, kind in PracticeBlock(kind: kind, title: String(localized: "practice.\(kind.rawValue)"), durationSeconds: kind == .reflection || kind == .journaling ? nil : minutes * 60, sortOrder: index, isOptional: kind == .reflection) }
        modelContext.insert(routine); dismiss()
    }
}

