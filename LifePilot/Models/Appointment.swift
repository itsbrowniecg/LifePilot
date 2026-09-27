//
//  Appointment.swift
//  LifePilot
//

import Foundation
import SwiftData

@Model
final class Appointment {
    var title: String
    var date: Date
    var location: String

    init(title: String, date: Date, location: String) {
        self.title = title
        self.date = date
        self.location = location
    }
}
