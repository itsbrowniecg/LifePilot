//
//  TasksView.swift
//  LifePilot
//

import SwiftUI

struct TasksView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Tasks are coming soon",
                systemImage: "checklist",
                description: Text("Your organized next actions will live here.")
            )
            .navigationTitle("Tasks")
        }
    }
}
