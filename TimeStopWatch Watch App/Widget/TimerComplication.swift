//
//  TimerComplication.swift
//  TimeStop
//
//  Created by Agent on 2/2/26.
//

import SwiftUI
import WidgetKit

// MARK: - Widget Entry

struct TimerEntry: TimelineEntry {
    let date: Date
    let timerState: TimerState
    
    enum TimerState: String {
        case ready = "Ready"
        case running = "Running"
        case stopped = "Stopped"
    }
}

// MARK: - Widget Provider

struct TimerComplicationProvider: TimelineProvider {
    func placeholder(in context: Context) -> TimerEntry {
        TimerEntry(date: Date(), timerState: .ready)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TimerEntry) -> Void) {
        let entry = TimerEntry(date: Date(), timerState: .ready)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TimerEntry>) -> Void) {
        // For now, provide a simple timeline with ready state
        // In a full implementation, this would sync with app state via App Groups
        let entry = TimerEntry(date: Date(), timerState: .ready)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

// MARK: - Widget Views

struct TimerComplicationView: View {
    var entry: TimerEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            circularView
        case .accessoryRectangular:
            rectangularView
        default:
            circularView
        }
    }
    
    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 2) {
                Image(systemName: iconName)
                    .font(.system(size: 20))
                Text(entry.timerState.rawValue.prefix(3))
                    .font(.system(size: 10, weight: .medium))
            }
        }
    }
    
    private var rectangularView: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 24))
            VStack(alignment: .leading, spacing: 2) {
                Text("TimeSense")
                    .font(.system(size: 12, weight: .semibold))
                Text(entry.timerState.rawValue)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 8)
    }
    
    private var iconName: String {
        switch entry.timerState {
        case .ready:
            return "timer"
        case .running:
            return "timer.circle.fill"
        case .stopped:
            return "checkmark.circle.fill"
        }
    }
}

// MARK: - Widget Configuration
// NOTE: @main attribute removed - will be added when this file is moved to a separate Widget Extension target
// To complete Widget setup:
// 1. In Xcode: File > New > Target > Widget Extension
// 2. Move this file to the new Widget Extension target
// 3. Restore @main attribute below
// 4. Remove this file from TimeStopWatch Watch App target

struct TimerComplication: Widget {
    let kind: String = "TimerComplication"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimerComplicationProvider()) { entry in
            TimerComplicationView(entry: entry)
        }
        .configurationDisplayName("Timer Status")
        .description("Shows the current timer state")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}

// MARK: - Previews

#Preview("Circular - Ready", as: .accessoryCircular) {
    TimerComplication()
} timeline: {
    TimerEntry(date: .now, timerState: .ready)
}

#Preview("Circular - Running", as: .accessoryCircular) {
    TimerComplication()
} timeline: {
    TimerEntry(date: .now, timerState: .running)
}

#Preview("Circular - Stopped", as: .accessoryCircular) {
    TimerComplication()
} timeline: {
    TimerEntry(date: .now, timerState: .stopped)
}

#Preview("Rectangular - Ready", as: .accessoryRectangular) {
    TimerComplication()
} timeline: {
    TimerEntry(date: .now, timerState: .ready)
}

#Preview("Rectangular - Running", as: .accessoryRectangular) {
    TimerComplication()
} timeline: {
    TimerEntry(date: .now, timerState: .running)
}

#Preview("Rectangular - Stopped", as: .accessoryRectangular) {
    TimerComplication()
} timeline: {
    TimerEntry(date: .now, timerState: .stopped)
}
