//
//  InboxItem.swift
//  LifePilot
//

import Foundation
import SwiftData

@Model
final class InboxItem {
    var title: String
    var type: String
    var createdAt: Date
    var notes: String

    init(title: String, type: String, createdAt: Date = .now, notes: String = "") {
        self.title = title
        self.type = type
        self.createdAt = createdAt
        self.notes = notes
    }
}
