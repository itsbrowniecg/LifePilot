//
//  AIService.swift
//  LifePilot
//

import Foundation

/// The app never contains an AI provider key. A server-side implementation can
/// later conform here without changing any view or SwiftData code.
protocol AIServiceProtocol: Sendable {
    func analyze(capturedText: String) async -> AIAnalysisResponse
}

struct MockAIService: AIServiceProtocol {
    func analyze(capturedText: String) async -> AIAnalysisResponse {
        return AIAnalysisResponse(result: result(for: capturedText), source: .mock, notice: nil)
    }

    private func result(for text: String) -> AIResult {
        let normalized = text.lowercased()
        let receiptGroceries = groceries(in: text)
        if receiptGroceries.count >= 2, receiptGroceries.contains(where: { $0.name.lowercased() == "eggs" || $0.name.lowercased() == "chicken" }) {
            return AIResult(type: .grocery, title: "Grocery receipt", action: "Add to pantry", notes: text, dueDate: nil, amount: nil, category: GroceryCategory.pantry.rawValue, priority: .low, groceries: receiptGroceries)
        }
        if normalized.contains("cs assignment") || normalized.contains("assignment") {
            return AIResult(type: .task, title: "CS assignment", action: "Complete CS assignment", notes: text, dueDate: tonight(), amount: nil, category: "School", priority: .high, groceries: nil)
        }
        if normalized.contains("electricity") || normalized.contains("electric bill") {
            return AIResult(type: .bill, title: "Electricity bill", action: "Pay electricity bill", notes: text, dueDate: tomorrow(), amount: 83.42, category: "Utilities", priority: .high, groceries: nil)
        }
        if normalized.contains("detergent") {
            return AIResult(type: .task, title: "Buy detergent", action: "Buy detergent", notes: text, dueDate: Calendar.current.date(byAdding: .day, value: 2, to: .now), amount: nil, category: "Errands", priority: .medium, groceries: nil)
        }
        if normalized.contains("spinach") {
            return AIResult(type: .grocery, title: "Spinach", action: "Use spinach", notes: text, dueDate: .now, amount: nil, category: GroceryCategory.plants.rawValue, priority: .high, groceries: [CapturedGrocery(name: "Spinach", category: GroceryCategory.plants.rawValue)])
        }
        if normalized.contains("doctor") || normalized.contains("appointment") {
            let appointmentDay = normalized.contains("tomorrow") ? Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now : .now
            let date = Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: appointmentDay) ?? appointmentDay
            return AIResult(type: .appointment, title: "Doctor appointment", action: "Attend doctor appointment", notes: text, dueDate: date, amount: nil, category: "Health", priority: .high, groceries: nil)
        }
        if normalized.contains("grocery") || normalized.contains("milk") || normalized.contains("rice") {
            return AIResult(type: .grocery, title: "Grocery receipt", action: "Add to pantry", notes: text, dueDate: nil, amount: nil, category: GroceryCategory.pantry.rawValue, priority: .low, groceries: receiptGroceries.isEmpty ? demoGroceries() : receiptGroceries)
        }
        return AIResult(type: .note, title: cleanedTitle(text, fallback: "Note"), action: nil, notes: text, dueDate: nil, amount: nil, category: nil, priority: .low, groceries: nil)
    }

    private func cleanedTitle(_ text: String, fallback: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : String(trimmed.prefix(80))
    }

    private func tonight() -> Date { Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: .now) ?? .now }
    private func tomorrow() -> Date { Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now }
    private func groceries(in text: String) -> [CapturedGrocery] {
        let values: [(String, GroceryCategory)] = [("Eggs", .protein), ("Chicken", .protein), ("Spinach", .plants), ("Rice", .carbs), ("Milk", .dairy)]
        let found = values.filter { text.lowercased().contains($0.0.lowercased()) }.map { CapturedGrocery(name: $0.0, category: $0.1.rawValue) }
        return found
    }
    private func demoGroceries() -> [CapturedGrocery] {
        [("Eggs", GroceryCategory.protein), ("Chicken", .protein), ("Spinach", .plants), ("Rice", .carbs), ("Milk", .dairy)].map { CapturedGrocery(name: $0.0, category: $0.1.rawValue) }
    }
}

/// Secure-backend boundary. Intentionally local until a reviewed backend is
/// available; it avoids accidental transmission of private inbox text.
struct SecureBackendPlaceholderService: AIServiceProtocol {
    func analyze(capturedText: String) async -> AIAnalysisResponse {
        let fallback = await MockAIService().analyze(capturedText: capturedText)
        return AIAnalysisResponse(result: fallback.result, source: .fallback, notice: "Secure AI backend is not connected. LifePilot used its private on-device demo analysis.")
    }
}

enum AIServiceFactory {
    static func makeService() -> any AIServiceProtocol { MockAIService() }
}
