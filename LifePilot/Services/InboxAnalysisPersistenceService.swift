//
//  InboxAnalysisPersistenceService.swift
//  LifePilot
//

import Foundation
import SwiftData

enum InboxAnalysisPersistenceService {
    /// Applies a result exactly once for each inbox item. The inbox UUID is
    /// stored on created records, so repeated taps never create duplicates.
    static func apply(_ response: AIAnalysisResponse, to item: InboxItem, in context: ModelContext) throws {
        guard item.analysisState != "completed" else { return }

        let result = response.result
        item.type = result.type.rawValue
        item.title = result.title
        item.notes = result.notes ?? item.notes
        item.analysisState = "completed"
        item.analysisSummary = summary(for: result)
        item.analysisSource = response.source == .mock ? "Organized with Demo Mode" : "Organized with local fallback"
        item.analyzedAt = .now

        switch result.type {
        case .task:
            context.insert(Task(title: result.title, notes: result.notes ?? "", dueDate: result.dueDate ?? .now, sourceInboxID: item.id))
        case .bill:
            context.insert(Bill(title: result.title, amount: result.amount ?? 0, dueDate: result.dueDate ?? .now, category: result.category ?? "Other", sourceInboxID: item.id))
        case .grocery:
            let category = GroceryCategory(rawValue: result.category ?? "") ?? .other
            context.insert(Grocery(name: result.title, expirationDate: result.dueDate ?? Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now, quantity: 1, category: category.rawValue, sourceInboxID: item.id))
        case .appointment:
            context.insert(Appointment(title: result.title, date: result.dueDate ?? .now, location: result.category ?? "Details in Life Inbox", sourceInboxID: item.id))
        case .note:
            break
        }
        try context.save()
    }

    private static func summary(for result: AIResult) -> String {
        var parts = [result.type.rawValue.capitalized]
        if let action = result.action { parts.append(action) }
        if let dueDate = result.dueDate { parts.append(dueDate.formatted(date: .abbreviated, time: .shortened)) }
        if let amount = result.amount { parts.append(amount.formatted(.currency(code: "USD"))) }
        return parts.joined(separator: " · ")
    }
}
