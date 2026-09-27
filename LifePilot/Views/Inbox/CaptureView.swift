//
//  CaptureView.swift
//  LifePilot
//

import SwiftUI
import SwiftData

struct CaptureView: View {
    let aiService: any AIServiceProtocol
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var capturedText = ""
    @State private var isAnalyzing = false
    @State private var errorMessage: String?

    private var trimmedText: String { capturedText.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Drop in a reminder, bill, grocery, or appointment. LifePilot will organize it for you.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ZStack(alignment: .topLeading) {
                    if capturedText.isEmpty {
                        Text("What do you need to remember?")
                            .foregroundStyle(.tertiary).padding(.horizontal, 8).padding(.vertical, 12)
                    }
                    TextEditor(text: $capturedText).padding(4).accessibilityLabel("Life Inbox text")
                }
                .frame(minHeight: 180)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                if isAnalyzing {
                    HStack { ProgressView(); Text("LifePilot is organizing this…") }
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                if let errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle")
                        .font(.subheadline).foregroundStyle(.red)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Add to Life Inbox")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() }.disabled(isAnalyzing) }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isAnalyzing ? "Analyzing…" : "Analyze & Save") { analyzeAndSave() }
                        .disabled(trimmedText.isEmpty || isAnalyzing)
                }
            }
        }
    }

    private func analyzeAndSave() {
        isAnalyzing = true
        errorMessage = nil
        let text = trimmedText
        Swift.Task { @MainActor in
            let item = InboxItem(title: text, type: "note", notes: text)
            modelContext.insert(item)
            let response = await aiService.analyze(capturedText: text)
            do {
                try InboxAnalysisPersistenceService.apply(response, to: item, in: modelContext)
                dismiss()
            } catch {
                modelContext.delete(item)
                errorMessage = "Couldn’t save this item. Please try again."
                isAnalyzing = false
            }
        }
    }
}
