//
//  Grocery.swift
//  LifePilot
//

import Foundation
import SwiftData

enum GroceryCategory: String, CaseIterable {
    case plants
    case protein
    case carbs
    case beans
    case dairy
    case fats
    case pantry
    case drinks
    case snacks
    case other

    var emoji: String {
        switch self {
        case .plants: "🥬"
        case .protein: "💪"
        case .carbs: "🍚"
        case .beans: "🫘"
        case .dairy: "🥛"
        case .fats: "🥑"
        case .pantry: "🥫"
        case .drinks: "🥤"
        case .snacks: "🍪"
        case .other: "📦"
        }
    }

    var title: String {
        rawValue.capitalized
    }
}

@Model
final class Grocery {
    var name: String
    var expirationDate: Date
    var quantity: Int
    var category: String = GroceryCategory.other.rawValue

    init(name: String, expirationDate: Date, quantity: Int, category: String = GroceryCategory.other.rawValue) {
        self.name = name
        self.expirationDate = expirationDate
        self.quantity = quantity
        self.category = category
    }

    var groceryCategory: GroceryCategory {
        GroceryCategory(rawValue: category) ?? .other
    }
}
