//
//  CaptureView.swift
//  LifePilot
//

import SwiftUI
import SwiftData

struct CaptureView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var capturedText = ""

    private var trimmedText: String {
        capturedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                ZStack(alignment: .topLeading) {
                    if capturedText.isEmpty {
                        Text("What do you need to remember?")
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
                    }

                    TextEditor(text: $capturedText)
                        .padding(4)
                }
                .frame(minHeight: 180)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                Spacer()
            }
            .padding()
            .navigationTitle("Add to Life Inbox")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(trimmedText.isEmpty)
                }
            }
        }
    }

    private func save() {
        let item = InboxItem(
            title: trimmedText,
            type: "note",
            createdAt: .now,
            notes: trimmedText
        )
        modelContext.insert(item)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            assertionFailure("Unable to save Inbox item: \(error)")
        }
    }
}
