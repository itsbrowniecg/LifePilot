//
//  Bill.swift
//  LifePilot
//

import Foundation
import SwiftData

@Model
final class Bill {
    var title: String
    var amount: Double
    var dueDate: Date
    var isPaid: Bool
    var category: String
    var sourceInboxID: String = ""

    init(title: String, amount: Double, dueDate: Date, isPaid: Bool = false, category: String, sourceInboxID: String = "") {
        self.title = title
        self.amount = amount
        self.dueDate = dueDate
        self.isPaid = isPaid
        self.category = category
        self.sourceInboxID = sourceInboxID
    }
}
