import AppIntents
import SwiftUI
import WidgetKit

struct QuietMomentEntry: TimelineEntry { let date: Date }
struct QuietMomentProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuietMomentEntry { QuietMomentEntry(date: .now) }
    func getSnapshot(in context: Context, completion: @escaping (QuietMomentEntry) -> Void) { completion(QuietMomentEntry(date: .now)) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<QuietMomentEntry>) -> Void) { completion(Timeline(entries: [QuietMomentEntry(date: .now)], policy: .after(Calendar.current.date(byAdding: .hour, value: 6, to: .now)!))) }
}

struct QuietMomentWidget: Widget {
    let kind = "QuietMomentWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuietMomentProvider()) { _ in
            Link(destination: URL(string: "stillpath://practice/daily")!) {
                VStack(alignment: .leading, spacing: 10) { Image(systemName: "circle.hexagongrid.fill").font(.title).foregroundStyle(Color(red: 0.25, green: 0.40, blue: 0.34)); Spacer(); Text("widget.quietMoment").font(.headline); Text("widget.ready").font(.caption).foregroundStyle(.secondary) }.containerBackground(for: .widget) { Color(red: 0.96, green: 0.94, blue: 0.89) }
            }
        }.configurationDisplayName("widget.name").description("widget.description").supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

@main struct StillPathWidgetBundle: WidgetBundle { var body: some Widget { QuietMomentWidget() } }

