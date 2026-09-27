//
//  AIService.swift
//  LifePilot
//

import Foundation

protocol AIServiceProtocol: Sendable {
    func analyze(capturedText: String) async -> AIResult
}

struct MockAIService: AIServiceProtocol {
    func analyze(capturedText: String) async -> AIResult {
        let normalizedText = capturedText.lowercased()

        if normalizedText.contains("cs assignment") {
            return AIResult(
                type: .task,
                title: "CS assignment",
                action: "Complete CS assignment",
                notes: "Mock result for a captured assignment.",
                dueDate: tonight(),
                amount: nil,
                category: "School",
                priority: .high
            )
        }

        if normalizedText.contains("electricity bill") {
            return AIResult(
                type: .bill,
                title: "Electricity bill",
                action: "Pay electricity bill",
                notes: "Mock result for a captured bill.",
                dueDate: tomorrow(),
                amount: 83.42,
                category: "Utilities",
                priority: .high
            )
        }

        if normalizedText.contains("grocery") {
            return AIResult(
                type: .grocery,
                title: "Grocery item",
                action: "Review grocery item",
                notes: "Mock result for a captured grocery item.",
                dueDate: nil,
                amount: nil,
                category: "Groceries",
                priority: .low
            )
        }

        return AIResult(
            type: .note,
            title: capturedText.trimmingCharacters(in: .whitespacesAndNewlines),
            action: nil,
            notes: "Mock result for an unclassified note.",
            dueDate: nil,
            amount: nil,
            category: nil,
            priority: .low
        )
    }

    private func tonight() -> Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: .now) ?? .now
    }

    private func tomorrow() -> Date {
        Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
    }
}

enum AIServiceFactory {
    static func makeService() -> any AIServiceProtocol {
        MockAIService()
    }
}
