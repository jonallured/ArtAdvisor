//
//  ArtAdvisorWidget.swift
//  ArtAdvisorWidget
//
//  Created by Jonathan Allured on 2/9/23.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let user = User.makeFake()
        return SimpleEntry(date: Date(), configuration: ConfigurationIntent(), user: user)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let user = User.makeFake()
        let entry = SimpleEntry(date: Date(), configuration: configuration, user: user)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let user = await User.makeMeQuery()
            
            var entries: [SimpleEntry] = []

            let currentDate = Date()
            for hourOffset in 0 ..< 5 {
                let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                let entry = SimpleEntry(date: entryDate, configuration: configuration, user: user)
                entries.append(entry)
            }

            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let user: User
}

struct ArtAdvisorWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(entry.user.name).font(.system(size: 36)).lineLimit(1)
            ForEach(entry.user.artworks) { artwork in
                Text(artwork.title).lineLimit(1)
            }
        }
    }
}

struct ArtAdvisorWidget: Widget {
    let kind: String = "ArtAdvisorWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            ArtAdvisorWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct ArtAdvisorWidget_Previews: PreviewProvider {
    static var previews: some View {
        ArtAdvisorWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), user: User.makeFake()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
