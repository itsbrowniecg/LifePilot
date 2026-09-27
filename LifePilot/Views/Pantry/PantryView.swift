//
//  PantryView.swift
//  LifePilot
//

import SwiftUI

struct PantryView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Your pantry is coming soon",
                systemImage: "cabinet",
                description: Text("Keep track of the food and household items you have on hand.")
            )
            .navigationTitle("Pantry")
        }
    }
}
