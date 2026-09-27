//
//  AIResult.swift
//  LifePilot
//

import Foundation

enum AIItemType: String, Codable, Sendable {
    case task
    case bill
    case grocery
    case appointment
    case note
}

enum AIPriority: String, Codable, Sendable {
    case high
    case medium
    case low
}

struct AIResult: Codable, Sendable, Equatable {
    let type: AIItemType
    let title: String
    let action: String?
    let notes: String?
    let dueDate: Date?
    let amount: Double?
    let category: String?
    let priority: AIPriority?
}

enum AIAnalysisSource: String, Sendable {
    case mock
    case fallback
}

struct AIAnalysisResponse: Sendable {
    let result: AIResult
    let source: AIAnalysisSource
    let notice: String?
}
