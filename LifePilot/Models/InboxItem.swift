//
//  InboxItem.swift
//  LifePilot
//

import Foundation
import SwiftData

@Model
final class InboxItem {
    var id: String = UUID().uuidString
    var title: String
    var type: String
    var createdAt: Date
    var notes: String
    var analysisState: String = "unprocessed"
    var analysisSummary: String = ""
    var analysisSource: String = ""
    var analyzedAt: Date?

    init(title: String, type: String, createdAt: Date = .now, notes: String = "", id: String = UUID().uuidString) {
        self.id = id
        self.title = title
        self.type = type
        self.createdAt = createdAt
        self.notes = notes
    }
}
