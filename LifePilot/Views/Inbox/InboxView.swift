//
//  InboxView.swift
//  LifePilot
//

import SwiftUI

struct InboxView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Your inbox is clear",
                systemImage: "tray",
                description: Text("Drop anything here. LifePilot will help figure out what to do next.")
            )
            .navigationTitle("Inbox")
        }
    }
}
