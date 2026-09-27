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
        let sourceText = normalized(item.notes)
        let existingItems = try context.fetch(FetchDescriptor<InboxItem>())
        if existingItems.contains(where: {
            $0.id != item.id &&
            $0.analysisState == "completed" &&
            $0.type == result.type.rawValue &&
            normalized($0.notes) == sourceText
        }) {
            context.delete(item)
            try context.save()
            return
        }

        item.type = result.type.rawValue
        item.title = result.title
        item.notes = result.notes ?? item.notes
        item.analysisState = "completed"
        item.analysisSummary = summary(for: result)
        item.analysisSource = response.source == .mock ? "Organized with Demo Mode" : "Organized with local fallback"
        item.analyzedAt = .now

        switch result.type {
        case .task:
            let dueDate = result.dueDate ?? .now
            let duplicate = try context.fetch(FetchDescriptor<Task>()).contains { $0.title.caseInsensitiveCompare(result.title) == .orderedSame && Calendar.current.isDate($0.dueDate, inSameDayAs: dueDate) }
            if !duplicate { context.insert(Task(title: result.title, notes: result.notes ?? "", dueDate: dueDate, sourceInboxID: item.id)) }
        case .bill:
            let dueDate = result.dueDate ?? .now
            let amount = result.amount ?? 0
            let duplicate = try context.fetch(FetchDescriptor<Bill>()).contains { $0.title.caseInsensitiveCompare(result.title) == .orderedSame && $0.amount == amount && Calendar.current.isDate($0.dueDate, inSameDayAs: dueDate) }
            if !duplicate { context.insert(Bill(title: result.title, amount: amount, dueDate: dueDate, category: result.category ?? "Other", sourceInboxID: item.id)) }
        case .grocery:
            let groceries = result.groceries ?? [CapturedGrocery(name: result.title, category: result.category ?? GroceryCategory.other.rawValue)]
            for grocery in groceries {
                let existing = try context.fetch(FetchDescriptor<Grocery>()).first { $0.name.caseInsensitiveCompare(grocery.name) == .orderedSame }
                if let existing {
                    existing.quantity += 1
                } else {
                    context.insert(Grocery(name: grocery.name, expirationDate: result.dueDate ?? Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now, quantity: 1, category: grocery.category, sourceInboxID: item.id))
                }
            }
        case .appointment:
            let date = result.dueDate ?? .now
            let duplicate = try context.fetch(FetchDescriptor<Appointment>()).contains { $0.title.caseInsensitiveCompare(result.title) == .orderedSame && Calendar.current.isDate($0.date, equalTo: date, toGranularity: .minute) }
            if !duplicate { context.insert(Appointment(title: result.title, date: date, location: result.category ?? "Details in Life Inbox", sourceInboxID: item.id)) }
        case .note:
            break
        }
        try context.save()
    }

    /// Keeps a single analyzed Inbox history item for an identical capture.
    /// This runs at launch to clean up duplicates created before the guard above existed.
    static func removeDuplicateInboxItems(in context: ModelContext) {
        guard let items = try? context.fetch(FetchDescriptor<InboxItem>()) else { return }
        var seen = Set<String>()
        var didDelete = false

        for item in items.sorted(by: { $0.createdAt < $1.createdAt }) where item.analysisState == "completed" {
            let key = "\(item.type)|\(normalized(item.notes))"
            if seen.contains(key) {
                context.delete(item)
                didDelete = true
            } else {
                seen.insert(key)
            }
        }

        guard didDelete else { return }
        try? context.save()
    }

    private static func summary(for result: AIResult) -> String {
        var parts = [result.type.rawValue.capitalized]
        if let action = result.action { parts.append(action) }
        if let dueDate = result.dueDate { parts.append(dueDate.formatted(date: .abbreviated, time: .shortened)) }
        if let amount = result.amount { parts.append(amount.formatted(.currency(code: "USD"))) }
        return parts.joined(separator: " · ")
    }

    private static func normalized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}
