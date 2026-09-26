import SwiftData
import SwiftUI

struct JourneyView: View {
    @Query(sort: \PracticeSession.startedAt, order: .reverse) private var sessions: [PracticeSession]
    @Query(sort: \JournalEntry.createdAt, order: .reverse) private var entries: [JournalEntry]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private var activeDays: Set<Date> { Set(sessions.map { Calendar.current.startOfDay(for: $0.startedAt) } + entries.map { Calendar.current.startOfDay(for: $0.createdAt) }) }

    var body: some View {
        ZStack {
            CalmBackground()
            ScrollView { VStack(alignment: .leading, spacing: StillPathSpacing.lg) {
                StillPathCard { VStack(alignment: .leading, spacing: StillPathSpacing.sm) { Text("journey.monthSummary").font(.title3.bold()); Text("journey.days \(daysThisMonth)").font(.system(.title2, design: .serif)); Text("journey.noPressure").foregroundStyle(.secondary) } }
                VStack(alignment: .leading) { Text(Date.now, format: .dateTime.month(.wide).year()).font(.headline); LazyVGrid(columns: columns) { ForEach(monthDays, id: \.self) { date in Text("\(Calendar.current.component(.day, from: date))").frame(maxWidth: .infinity, minHeight: 40).background(activeDays.contains(Calendar.current.startOfDay(for: date)) ? StillPathColor.sage : Color(.secondarySystemBackground), in: Circle()).foregroundStyle(activeDays.contains(Calendar.current.startOfDay(for: date)) ? .white : .primary).accessibilityLabel(date.formatted(date: .long, time: .omitted)) } } }
                if !sessions.isEmpty { VStack(alignment: .leading, spacing: StillPathSpacing.sm) { Text("journey.recent").font(.headline); ForEach(sessions.prefix(5)) { session in HStack { Image(systemName: "circle.fill").font(.caption).foregroundStyle(StillPathColor.sage); VStack(alignment: .leading) { Text(session.routineName); Text(session.startedAt, format: .dateTime.day().month().hour().minute()).font(.caption).foregroundStyle(.secondary) }; Spacer() } } } }
            }.padding() }
        }.navigationTitle("journey.title")
    }

    private var monthDays: [Date] { let calendar = Calendar.current; let range = calendar.range(of: .day, in: .month, for: .now) ?? 1..<2; let start = calendar.date(from: calendar.dateComponents([.year, .month], from: .now)) ?? .now; return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: start) } }
    private var daysThisMonth: Int { let month = Calendar.current.component(.month, from: .now); return activeDays.filter { Calendar.current.component(.month, from: $0) == month }.count }
}

