//
//  HomeView.swift
//  LifePilot
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Task.dueDate) private var tasks: [Task]
    @Query(sort: \Bill.dueDate) private var bills: [Bill]
    @Query(sort: \Grocery.expirationDate) private var groceries: [Grocery]
    @Query(sort: \Appointment.date) private var appointments: [Appointment]
    @State private var dismissedRecommendationIDs: Set<PersistentIdentifier> = []

    private var recommendations: [PrioritizedRecommendation] {
        PrioritizationService.recommendations(
            tasks: tasks,
            bills: bills,
            groceries: groceries,
            appointments: appointments
        )
        .filter { !dismissedRecommendationIDs.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Good morning 👋")
                        .font(.title.bold())

                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("WHAT SHOULD I DO NOW?")
                                .font(.headline)

                            Spacer()

                            NavigationLink("See all") {
                                TasksView()
                            }
                            .font(.subheadline.weight(.semibold))
                        }

                        if recommendations.isEmpty {
                            ContentUnavailableView(
                                "You’re all caught up",
                                systemImage: "checkmark.circle",
                                description: Text("New recommendations will appear here when something needs attention.")
                            )
                            .frame(maxWidth: .infinity)
                        } else {
                            ForEach(recommendations) { recommendation in
                                recommendationView(recommendation)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .padding()
            }
            .navigationTitle("LifePilot")
        }
    }

    @ViewBuilder
    private func recommendationView(_ recommendation: PrioritizedRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: iconName(for: recommendation.sourceType))
                    .foregroundStyle(priorityColor(for: recommendation.priority))
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.title)
                        .font(.headline)

                    Text(recommendation.reason)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(recommendation.priority.title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(priorityColor(for: recommendation.priority))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(priorityColor(for: recommendation.priority).opacity(0.14), in: Capsule())
            }

            HStack(spacing: 8) {
                if let amount = recommendation.amount {
                    Text(amount, format: .currency(code: "USD"))
                }

                if recommendation.amount != nil, recommendation.dueDate != nil {
                    Text("•")
                }

                if let dueDate = recommendation.dueDate {
                    Text(dueDate, format: .dateTime.weekday().month().day().hour().minute())
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack {
                Button("Complete") {
                    complete(recommendation)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)

                Button("Dismiss") {
                    dismiss(recommendation)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
    }

    private func complete(_ recommendation: PrioritizedRecommendation) {
        switch recommendation.sourceType {
        case .task:
            guard let task = tasks.first(where: { $0.persistentModelID == recommendation.id }) else { return }
            task.isCompleted = true
            saveChanges()
        case .bill:
            guard let bill = bills.first(where: { $0.persistentModelID == recommendation.id }) else { return }
            bill.isPaid = true
            saveChanges()
        case .grocery, .appointment:
            dismiss(recommendation)
        }
    }

    private func dismiss(_ recommendation: PrioritizedRecommendation) {
        dismissedRecommendationIDs.insert(recommendation.id)
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            assertionFailure("Unable to save recommendation action: \(error)")
        }
    }

    private func iconName(for sourceType: RecommendationSourceType) -> String {
        switch sourceType {
        case .task: "checklist"
        case .bill: "doc.text"
        case .grocery: "leaf"
        case .appointment: "calendar"
        }
    }

    private func priorityColor(for priority: RecommendationPriority) -> Color {
        switch priority {
        case .high: .red
        case .medium: .orange
        case .low: .secondary
        }
    }
}
