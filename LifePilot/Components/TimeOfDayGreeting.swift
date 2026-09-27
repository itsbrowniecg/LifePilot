//
//  TimeOfDayGreeting.swift
//  LifePilot
//

import SwiftUI

enum TimeOfDay {
    case morning
    case afternoon
    case evening
    case night

    static func current(date: Date = .now, calendar: Calendar = .current) -> TimeOfDay {
        switch calendar.component(.hour, from: date) {
        case 5..<12: .morning
        case 12..<17: .afternoon
        case 17..<22: .evening
        default: .night
        }
    }

    var greeting: String {
        switch self {
        case .morning: "Good morning ☀️"
        case .afternoon: "Good afternoon 🌤️"
        case .evening: "Good evening 🌆"
        case .night: "Wind down 🌙"
        }
    }

    var supportingText: String {
        switch self {
        case .morning: "Let's get your day moving."
        case .afternoon: "Here's what still needs your attention."
        case .evening: "Let's wrap up what matters today."
        case .night: "Here's what can wait until tomorrow."
        }
    }

    var accentColor: Color {
        switch self {
        case .morning: .orange
        case .afternoon: .blue
        case .evening: .indigo
        case .night: .purple
        }
    }
}

struct TimeOfDayGreeting: View {
    let timeOfDay: TimeOfDay

    init(timeOfDay: TimeOfDay = .current()) {
        self.timeOfDay = timeOfDay
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(timeOfDay.greeting)
                .font(.title.bold())

            Text(timeOfDay.supportingText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(timeOfDay.accentColor.opacity(0.10), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
