//
//  InboxView.swift
//  LifePilot
//

import SwiftUI
import SwiftData

struct InboxView: View {
    @Query(sort: \InboxItem.createdAt, order: .reverse) private var inboxItems: [InboxItem]

    var body: some View {
        NavigationStack {
            List(inboxItems) { item in
                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                        Text(item.type)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: iconName(for: item.type))
                }
            }
            .overlay {
                if inboxItems.isEmpty {
                    ContentUnavailableView(
                        "Your inbox is clear",
                        systemImage: "tray",
                        description: Text("Drop anything here. LifePilot will help figure out what to do next.")
                    )
                }
            }
            .navigationTitle("Inbox")
        }
    }

    private func iconName(for type: String) -> String {
        switch type.lowercased() {
        case "bill": "doc.text"
        case "task": "checklist"
        case "receipt": "receipt"
        default: "tray"
        }
    }
}
