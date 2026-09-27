//
//  Task.swift
//  LifePilot
//

import Foundation
import SwiftData

@Model
final class Task {
    var title: String
    var notes: String
    var dueDate: Date
    var isCompleted: Bool

    init(title: String, notes: String = "", dueDate: Date, isCompleted: Bool = false) {
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.isCompleted = isCompleted
    }
}
