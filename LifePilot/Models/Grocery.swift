//
//  Grocery.swift
//  LifePilot
//

import Foundation
import SwiftData

@Model
final class Grocery {
    var name: String
    var expirationDate: Date
    var quantity: Int

    init(name: String, expirationDate: Date, quantity: Int) {
        self.name = name
        self.expirationDate = expirationDate
        self.quantity = quantity
    }
}
