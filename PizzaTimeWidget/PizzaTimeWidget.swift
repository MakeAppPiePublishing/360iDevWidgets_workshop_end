//
//  PizzaTimeWidget.swift
//  PizzaTimeWidget
//
//  Created by Steven Lipton on 8/22/21.
//

import WidgetKit
import SwiftUI

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(),stage: 1)
    }

    func getSnapshot(for configuration: ConfigurationIntent ,in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(),stage:0,configuration:configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent ,in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let date = Date()
        for stage in 0..<stages.count{
            let scheduled = date + Double(stage * 3)
            let entry = SimpleEntry(date: scheduled, stage: stage, configuration:configuration)
            entries.append(entry)
        }
        let entry = SimpleEntry(date: Date() + Double(stages.count * 3 + 3), stage: 0, configuration:configuration)
        entries.append(entry)
        
        

        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let stage:Int
    var configuration: ConfigurationIntent? = nil
    var color:String{
        if let color = configuration?.color{
            switch color{
            case .green:
                return "green"
            case .lightBlue:
                return "lightBlue"
            default:
                return "ochre"
            }
        }
        var location:String{
            if let theLocation = configuration?.location{
                theLocation
            }
        }
        return "ochre"
    }
}

struct PizzaTimeWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    var body: some View {
        switch family{
        case .systemSmall:
            DeliveryView(stage: .constant(entry.stage),color:entry.color)
        case    .systemMedium:
            DeliveryViewMedium(stage: .constant(entry.stage),configuration: entry.configuration,color:entry.color)
        case    .systemLarge:
            DeliveryViewLarge(stage: .constant(entry.stage),color:entry.color)
        default:
            DeliveryView(stage: .constant(entry.stage),color:entry.color)
        }
       
    }
}

@main
struct PizzaTimeWidget: Widget {
    let kind: String = "PizzaTimeWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind,intent:ConfigurationIntent.self,  provider: Provider()) { entry in
            PizzaTimeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Huli Pizza Delivery")
        .description("The widget to know where your pizza is")
        .supportedFamilies([.systemSmall,.systemMedium,.systemLarge])
    }
}

struct PizzaTimeWidget_Previews: PreviewProvider {
    static var previews: some View {
        PizzaTimeWidgetEntryView(entry: SimpleEntry(date: Date(),stage:0))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
