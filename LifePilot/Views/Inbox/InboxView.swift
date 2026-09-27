//
//  InboxView.swift
//  LifePilot
//

import SwiftUI
import SwiftData

struct InboxView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \InboxItem.createdAt, order: .reverse) private var inboxItems: [InboxItem]
    @State private var isPresentingCapture = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        isPresentingCapture = true
                    } label: {
                        Label("Add to Life Inbox", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowBackground(Color.clear)
                }

                if inboxItems.isEmpty {
                    Section {
                        ContentUnavailableView(
                            "Drop anything here.",
                            systemImage: "tray",
                            description: Text("LifePilot will help figure out what to do next.")
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                    }
                } else {
                    Section("Saved items") {
                        ForEach(inboxItems) { item in
                            Label {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                    Text("\(item.type.capitalized) · \(item.createdAt, format: .dateTime.month().day().hour().minute())")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            } icon: {
                                Image(systemName: iconName(for: item.type))
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
            }
            .navigationTitle("Inbox")
            .sheet(isPresented: $isPresentingCapture) {
                CaptureView()
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(inboxItems[index])
        }

        saveChanges()
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            assertionFailure("Unable to save Inbox changes: \(error)")
        }
    }

    private func iconName(for type: String) -> String {
        switch type.lowercased() {
        case "bill": "doc.text"
        case "task": "checklist"
        case "receipt": "receipt"
        case "note": "note.text"
        default: "tray"
        }
    }
}
