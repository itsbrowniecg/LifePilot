//
//  TasksView.swift
//  LifePilot
//

import SwiftUI
import SwiftData

struct TasksView: View {
    @Query(sort: \Task.dueDate) private var tasks: [Task]

    var body: some View {
        NavigationStack {
            List(tasks) { task in
                HStack(spacing: 12) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(task.isCompleted ? .green : .secondary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                        Text("Due \(task.dueDate, format: .dateTime.weekday().month().day())")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .overlay {
                if tasks.isEmpty {
                    ContentUnavailableView("No tasks yet", systemImage: "checklist")
                }
            }
            .navigationTitle("Tasks")
        }
    }
}
