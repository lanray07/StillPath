import SwiftData
import SwiftUI

struct JournalView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \JournalEntry.createdAt, order: .reverse) private var entries: [JournalEntry]
    @State private var search = ""

    private var filtered: [JournalEntry] {
        guard !search.isEmpty else { return entries }
        return entries.filter { $0.title.localizedStandardContains(search) || $0.body.localizedStandardContains(search) || $0.tags.contains(where: { $0.localizedStandardContains(search) }) }
    }

    var body: some View {
        ZStack {
            CalmBackground()
            if filtered.isEmpty { ContentUnavailableView(LocalizedStringKey(search.isEmpty ? "journal.empty.title" : "journal.search.empty"), systemImage: "book.closed", description: Text(LocalizedStringKey(search.isEmpty ? "journal.empty.body" : "journal.search.body"))) }
            else { List(filtered) { entry in NavigationLink(value: entry.persistentModelID) { JournalRow(entry: entry) } }.scrollContentBackground(.hidden).navigationDestination(for: PersistentIdentifier.self) { id in JournalDetailView(entryID: id) } }
        }
        .navigationTitle("journal.title").searchable(text: $search, prompt: "journal.search")
        .toolbar { Button { appState.presentedSheet = .newJournal } label: { Label("journal.new", systemImage: "square.and.pencil") } }
    }
}

private struct JournalRow: View {
    let entry: JournalEntry
    var body: some View { VStack(alignment: .leading, spacing: StillPathSpacing.xs) { HStack { Text(entry.title.isEmpty ? String(localized: "journal.untitled") : entry.title).font(.headline); if entry.isFavourite { Image(systemName: "heart.fill").foregroundStyle(StillPathColor.clay) } }; Text(entry.body).lineLimit(2).foregroundStyle(.secondary); Text(entry.createdAt, format: .dateTime.day().month().year()).font(.caption).foregroundStyle(.tertiary) }.padding(.vertical, 6) }
}

struct JournalEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var title = ""
    @State private var bodyText = ""
    @State private var tags = ""
    @State private var recorder = VoiceRecorder()
    @FocusState private var focused: Bool

    var body: some View {
        Form {
            Section { TextField("journal.title.placeholder", text: $title); TextEditor(text: $bodyText).frame(minHeight: 240).focused($focused).accessibilityLabel("journal.body") }
            Section("journal.tags") { TextField("journal.tags.placeholder", text: $tags) }
            Section("voice.title") {
                Button { Task { await recorder.toggle() } } label: { Label(LocalizedStringKey(recorder.isRecording ? "voice.stop" : "voice.record"), systemImage: recorder.isRecording ? "stop.circle.fill" : "waveform.circle") }
                if recorder.recordedFileURL != nil, !recorder.isRecording { Label("voice.saved", systemImage: "checkmark.circle"); Button("voice.discard", role: .destructive) { recorder.discard() } }
                if let error = recorder.errorMessage { Text(error).font(.footnote).foregroundStyle(.red) }
                Text("voice.transcriptionNotice").font(.caption).foregroundStyle(.secondary)
            }
            Section { Label("journal.localNotice", systemImage: "lock.fill").font(.footnote).foregroundStyle(.secondary) }
        }.navigationTitle("journal.new").toolbar { ToolbarItem(placement: .cancellationAction) { Button("common.cancel") { dismiss() } }; ToolbarItem(placement: .confirmationAction) { Button("common.save") { save() }.disabled(bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) } }.onAppear { focused = true }
    }

    private func save() { recorder.stop(); let cleanTags = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }; let entry = JournalEntry(title: title, body: bodyText, tags: cleanTags); entry.audioFileName = recorder.recordedFileURL?.lastPathComponent; modelContext.insert(entry); dismiss() }
}

struct JournalDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let entryID: PersistentIdentifier
    @State private var showDelete = false
    private var entry: JournalEntry? { modelContext.model(for: entryID) as? JournalEntry }

    var body: some View {
        Group {
            if let entry { ScrollView { VStack(alignment: .leading, spacing: StillPathSpacing.md) { Text(entry.createdAt, format: .dateTime.weekday(.wide).day().month(.wide).year()).font(.subheadline).foregroundStyle(.secondary); Text(entry.body).font(.body).textSelection(.enabled); if !entry.tags.isEmpty { Text(entry.tags.map { "#\($0)" }.joined(separator: "  ")).font(.footnote).foregroundStyle(StillPathColor.sage) } }.frame(maxWidth: .infinity, alignment: .leading).padding() }.navigationTitle(entry.title.isEmpty ? "journal.untitled" : entry.title).toolbar { Button { entry.isFavourite.toggle() } label: { Image(systemName: entry.isFavourite ? "heart.fill" : "heart") }; Button(role: .destructive) { showDelete = true } label: { Image(systemName: "trash") } }.confirmationDialog("journal.delete.confirm", isPresented: $showDelete) { Button("common.delete", role: .destructive) { modelContext.delete(entry) } } }
            else { ContentUnavailableView("journal.missing", systemImage: "questionmark.folder") }
        }
    }
}

