//
//  PantryView.swift
//  LifePilot
//

import SwiftUI
import SwiftData

struct PantryView: View {
    @Query(sort: \Grocery.expirationDate) private var groceries: [Grocery]

    var body: some View {
        NavigationStack {
            List(groceries) { grocery in
                HStack(spacing: 12) {
                    Text(grocery.groceryCategory.emoji)
                        .font(.title2)
                        .frame(width: 34)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(grocery.name)
                            .font(.headline)

                        Text("\(grocery.groceryCategory.title) · \(availabilityText(for: grocery))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .overlay {
                if groceries.isEmpty {
                    ContentUnavailableView("Your pantry is empty", systemImage: "cabinet")
                }
            }
            .navigationTitle("Pantry")
        }
    }

    private func availabilityText(for grocery: Grocery) -> String {
        let calendar = Calendar.current

        if grocery.expirationDate < calendar.startOfDay(for: .now) {
            return "Expired"
        }
        if calendar.isDateInToday(grocery.expirationDate) {
            return "Expires today"
        }
        if calendar.isDateInTomorrow(grocery.expirationDate) {
            return "Expires tomorrow"
        }
        return "\(grocery.quantity) on hand · Expires \(grocery.expirationDate.formatted(date: .abbreviated, time: .omitted))"
    }
}
