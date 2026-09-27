//
//  PrioritizationService.swift
//  LifePilot
//

import Foundation
import SwiftData

enum RecommendationPriority: Int, Comparable {
    case high
    case medium
    case low

    static func < (lhs: RecommendationPriority, rhs: RecommendationPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var title: String {
        switch self {
        case .high: "HIGH"
        case .medium: "MEDIUM"
        case .low: "LOW"
        }
    }
}

enum RecommendationSourceType {
    case task
    case bill
    case grocery
    case appointment
}

struct PrioritizedRecommendation: Identifiable {
    let id: PersistentIdentifier
    let title: String
    let reason: String
    let sourceType: RecommendationSourceType
    let dueDate: Date?
    let amount: Double?
    let priority: RecommendationPriority
}

enum PrioritizationService {
    static func recommendations(
        tasks: [Task],
        bills: [Bill],
        groceries: [Grocery],
        appointments: [Appointment],
        now: Date = .now,
        calendar: Calendar = .current
    ) -> [PrioritizedRecommendation] {
        var recommendations: [PrioritizedRecommendation] = []

        for task in tasks where !task.isCompleted {
            let urgency = dateUrgency(for: task.dueDate, now: now, calendar: calendar)
            recommendations.append(
                PrioritizedRecommendation(
                    id: task.persistentModelID,
                    title: task.title,
                    reason: taskReason(for: urgency),
                    sourceType: .task,
                    dueDate: task.dueDate,
                    amount: nil,
                    priority: taskPriority(for: urgency)
                )
            )
        }

        for bill in bills where !bill.isPaid {
            let urgency = dateUrgency(for: bill.dueDate, now: now, calendar: calendar)
            recommendations.append(
                PrioritizedRecommendation(
                    id: bill.persistentModelID,
                    title: "Pay \(bill.title)",
                    reason: billReason(for: urgency),
                    sourceType: .bill,
                    dueDate: bill.dueDate,
                    amount: bill.amount,
                    priority: billPriority(for: urgency)
                )
            )
        }

        for grocery in groceries {
            let urgency = dateUrgency(for: grocery.expirationDate, now: now, calendar: calendar)
            recommendations.append(
                PrioritizedRecommendation(
                    id: grocery.persistentModelID,
                    title: "Use \(grocery.name)",
                    reason: groceryReason(for: urgency),
                    sourceType: .grocery,
                    dueDate: grocery.expirationDate,
                    amount: nil,
                    priority: groceryPriority(for: urgency)
                )
            )
        }

        for appointment in appointments {
            let urgency = dateUrgency(for: appointment.date, now: now, calendar: calendar)
            recommendations.append(
                PrioritizedRecommendation(
                    id: appointment.persistentModelID,
                    title: appointment.title,
                    reason: appointmentReason(for: urgency),
                    sourceType: .appointment,
                    dueDate: appointment.date,
                    amount: nil,
                    priority: appointmentPriority(for: urgency)
                )
            )
        }

        return Array(
            recommendations
                .sorted { lhs, rhs in
                    if lhs.priority != rhs.priority {
                        return lhs.priority < rhs.priority
                    }

                    return (lhs.dueDate ?? .distantFuture) < (rhs.dueDate ?? .distantFuture)
                }
                .prefix(3)
        )
    }

    private enum DateUrgency {
        case overdue
        case today
        case tomorrow
        case later
    }

    private static func dateUrgency(for date: Date, now: Date, calendar: Calendar) -> DateUrgency {
        let startOfToday = calendar.startOfDay(for: now)
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? startOfToday
        let startOfDayAfterTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfTomorrow) ?? startOfTomorrow

        if date < startOfToday {
            return .overdue
        }
        if date < startOfTomorrow {
            return .today
        }
        if date < startOfDayAfterTomorrow {
            return .tomorrow
        }
        return .later
    }

    private static func taskPriority(for urgency: DateUrgency) -> RecommendationPriority {
        switch urgency {
        case .overdue, .today: .high
        case .tomorrow: .medium
        case .later: .low
        }
    }

    private static func billPriority(for urgency: DateUrgency) -> RecommendationPriority {
        switch urgency {
        case .overdue, .today, .tomorrow: .high
        case .later: .medium
        }
    }

    private static func groceryPriority(for urgency: DateUrgency) -> RecommendationPriority {
        switch urgency {
        case .overdue, .today: .high
        case .tomorrow: .medium
        case .later: .low
        }
    }

    private static func appointmentPriority(for urgency: DateUrgency) -> RecommendationPriority {
        switch urgency {
        case .overdue, .today: .high
        case .tomorrow: .medium
        case .later: .low
        }
    }

    private static func taskReason(for urgency: DateUrgency) -> String {
        switch urgency {
        case .overdue: "Overdue"
        case .today: "Due today"
        case .tomorrow: "Due tomorrow"
        case .later: "Due later"
        }
    }

    private static func billReason(for urgency: DateUrgency) -> String {
        switch urgency {
        case .overdue: "Bill is overdue"
        case .today: "Bill is due today"
        case .tomorrow: "Bill is due tomorrow"
        case .later: "Upcoming bill"
        }
    }

    private static func groceryReason(for urgency: DateUrgency) -> String {
        switch urgency {
        case .overdue: "Expired"
        case .today: "Expires today"
        case .tomorrow: "Expires tomorrow"
        case .later: "Expires later"
        }
    }

    private static func appointmentReason(for urgency: DateUrgency) -> String {
        switch urgency {
        case .overdue: "Appointment time has passed"
        case .today: "Appointment today"
        case .tomorrow: "Appointment tomorrow"
        case .later: "Upcoming appointment"
        }
    }
}
