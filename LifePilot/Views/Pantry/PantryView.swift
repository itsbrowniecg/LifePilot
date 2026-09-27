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
                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(grocery.name)
                        Text("\(grocery.quantity) on hand · Expires \(grocery.expirationDate, format: .dateTime.month().day())")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "leaf")
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
}
