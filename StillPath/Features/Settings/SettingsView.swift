import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(PrivacySettings.self) private var privacy
    @Environment(EntitlementStore.self) private var entitlement
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.createdAt) private var journalEntries: [JournalEntry]
    @State private var showDeleteAll = false

    var body: some View {
        @Bindable var settings = privacy
        Form {
            Section { Button { appState.presentedSheet = .paywall } label: { HStack { Label("StillPath Premium", systemImage: "sparkles"); Spacer(); Text(LocalizedStringKey(entitlement.hasPremium ? "premium.active" : "premium.explore")).foregroundStyle(.secondary) } } }
            Section("settings.privacy") {
                Toggle("settings.appLock", isOn: $settings.requireBiometrics)
                Toggle("settings.ai", isOn: $settings.allowsAIProcessing)
                Toggle("settings.translation", isOn: $settings.allowsTranslation)
                Toggle("settings.analytics", isOn: $settings.allowsAnalytics)
                Toggle("settings.widgetPrivacy", isOn: $settings.allowsPrivateWidgetText)
                Toggle("settings.sync", isOn: $settings.allowsCloudSync)
            }
            Section("settings.language") { Picker("settings.language", selection: Binding(get: { appState.preferredLanguage }, set: { appState.preferredLanguage = $0 })) { Text("language.system").tag("system"); Text("English").tag("en"); Text("Español").tag("es"); Text("العربية").tag("ar"); Text("اردو").tag("ur") } }
            Section("reminders.title") { NavigationLink("reminders.configure") { ReminderSettingsView() } }
            Section("settings.data") {
                ShareLink(item: exportURL()) { Label("settings.export", systemImage: "square.and.arrow.up") }
                Button("settings.deleteAll", role: .destructive) { showDeleteAll = true }
            }
            Section("settings.about") { LabeledContent("settings.version", value: "1.0.0"); Text("settings.promise").font(.footnote).foregroundStyle(.secondary) }
        }.navigationTitle("settings.title").confirmationDialog("settings.deleteAll.confirm", isPresented: $showDeleteAll) { Button("settings.deleteAll", role: .destructive) { deleteAll() } }
    }

    private func exportURL() -> URL {
        let url = FileManager.default.temporaryDirectory.appending(path: "StillPath-Export.md")
        let export = journalEntries.map { entry in
            let title = entry.title.isEmpty ? String(localized: "journal.untitled") : entry.title
            let tags = entry.tags.map { "#\($0)" }.joined(separator: " ")
            return "# \(title)\n\n\(entry.createdAt.formatted(date: .long, time: .shortened))\n\n\(entry.body)\n\n\(tags)"
        }.joined(separator: "\n\n---\n\n")
        try? export.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
    private func deleteAll() { try? modelContext.delete(model: JournalEntry.self); try? modelContext.delete(model: PracticeSession.self) }
}

struct ReminderSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var reminders: [ReminderSchedule]
    @State private var time = Calendar.current.date(from: DateComponents(hour: 8)) ?? .now
    @State private var message = String(localized: "reminders.defaultMessage")
    @State private var weekdays: Set<Int> = Set(1...7)
    @State private var status: String?
    private let service = ReminderService()

    var body: some View {
        Form {
            enabledSection
            scheduleSection
            wordingSection
            pauseSection
            Button("common.save") { Task { await save() } }.buttonStyle(PrimaryButtonStyle()).listRowBackground(Color.clear)
            if let status { Text(status).font(.footnote).foregroundStyle(.secondary) }
        }.navigationTitle("reminders.title")
    }

    private var enabledSection: some View {
        Section { Toggle("reminders.enabled", isOn: enabledBinding) }
    }

    private var scheduleSection: some View {
        Section("reminders.schedule") {
            DatePicker("reminders.time", selection: $time, displayedComponents: .hourAndMinute)
            ForEach(1...7, id: \.self) { weekday in
                Toggle(Calendar.current.weekdaySymbols[weekday - 1], isOn: weekdayBinding(weekday))
            }
        }
    }

    private var wordingSection: some View {
        Section("reminders.wording") { TextField("reminders.message", text: $message, axis: .vertical) }
    }

    private var pauseSection: some View {
        Section("reminders.pause") {
            Button("reminders.pauseToday") { pause(days: 1) }
            Button("reminders.pauseWeek") { pause(days: 7) }
            Button("reminders.pauseIndefinitely") { pauseIndefinitely() }
        }
    }

    private var enabledBinding: Binding<Bool> {
        Binding(get: { reminders.first?.isEnabled ?? true }, set: { ensureReminder().isEnabled = $0 })
    }

    private func weekdayBinding(_ weekday: Int) -> Binding<Bool> {
        Binding(
            get: { weekdays.contains(weekday) },
            set: { isEnabled in
                if isEnabled { weekdays.insert(weekday) } else { weekdays.remove(weekday) }
            }
        )
    }

    private func ensureReminder() -> ReminderSchedule { if let existing = reminders.first { return existing }; let reminder = ReminderSchedule(message: message); modelContext.insert(reminder); return reminder }
    private func pause(days: Int) { let reminder = ensureReminder(); reminder.pausedUntil = Calendar.current.date(byAdding: .day, value: days, to: .now); service.cancel(id: reminder.id) }
    private func pauseIndefinitely() { let reminder = ensureReminder(); reminder.isEnabled = false; service.cancel(id: reminder.id) }
    private func save() async {
        do {
            guard try await service.requestAuthorization() else {
                status = String(localized: "reminders.permissionDenied")
                return
            }
            let reminder = ensureReminder()
            let components = Calendar.current.dateComponents([.hour, .minute], from: time)
            reminder.hour = components.hour ?? 8
            reminder.minute = components.minute ?? 0
            reminder.weekdayValues = weekdays.sorted()
            reminder.message = message
            reminder.pausedUntil = nil
            let request = ReminderRequest(
                id: reminder.id,
                hour: reminder.hour,
                minute: reminder.minute,
                weekdays: reminder.weekdayValues,
                message: reminder.message,
                isEnabled: reminder.isEnabled,
                pausedUntil: reminder.pausedUntil
            )
            try await service.schedule(request)
            status = String(localized: "reminders.saved")
        } catch {
            status = error.localizedDescription
        }
    }
}
