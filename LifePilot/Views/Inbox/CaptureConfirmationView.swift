import SwiftUI
import SwiftData

struct CaptureConfirmationView: View {
    let response: AIAnalysisResponse
    let sourceText: String
    let onFinished: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var title: String
    @State private var notes: String
    @State private var amount: String
    @State private var dueDate: Date
    @State private var hasDueDate: Bool
    @State private var isSaving = false
    @State private var didSave = false
    @State private var message: String?
    private let eventKit = EventKitService()

    init(response: AIAnalysisResponse, sourceText: String, onFinished: @escaping () -> Void) {
        self.response = response
        self.sourceText = sourceText
        self.onFinished = onFinished
        _title = State(initialValue: response.result.title)
        _notes = State(initialValue: response.result.notes ?? sourceText)
        _amount = State(initialValue: response.result.amount.map { String(format: "%.2f", $0) } ?? "")
        _dueDate = State(initialValue: response.result.dueDate ?? .now)
        _hasDueDate = State(initialValue: response.result.dueDate != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("LifePilot found") {
                    LabeledContent("Type", value: response.result.type.rawValue.capitalized)
                    TextField("Title", text: $title)
                    TextField("Action", text: .constant(response.result.action ?? ""))
                        .disabled(true)
                    if response.result.type == .bill { TextField("Amount", text: $amount).keyboardType(.decimalPad) }
                    Toggle("Include date", isOn: $hasDueDate)
                    if hasDueDate { DatePicker("Date", selection: $dueDate) }
                    TextField("Notes", text: $notes, axis: .vertical).lineLimit(3...6)
                }
                if let groceries = response.result.groceries, !groceries.isEmpty {
                    Section("I found these groceries") {
                        ForEach(groceries) { grocery in
                            HStack { Text((GroceryCategory(rawValue: grocery.category) ?? .other).emoji); Text(grocery.name); Spacer(); Text((GroceryCategory(rawValue: grocery.category) ?? .other).title).foregroundStyle(.secondary) }
                        }
                    }
                }
                if let message { Section { Text(message).foregroundStyle(.secondary) } }
                if didSave, response.result.type == .appointment {
                    Section { Button("Add to Calendar", systemImage: "calendar.badge.plus") { addToCalendar() } }
                }
                if didSave, response.result.type == .bill || response.result.type == .task {
                    Section { Button("Add Reminder", systemImage: "bell.badge") { addReminder() } }
                }
            }
            .navigationTitle("Review capture")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(didSave ? "Done" : saveTitle) {
                        if didSave { onFinished(); dismiss() } else { save() }
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                }
            }
        }
    }

    private var saveTitle: String { response.result.type == .grocery ? "Add to Pantry" : "Looks Good" }

    private func editedResponse() -> AIAnalysisResponse {
        let result = AIResult(type: response.result.type, title: title.trimmingCharacters(in: .whitespacesAndNewlines), action: response.result.action, notes: notes, dueDate: hasDueDate ? dueDate : nil, amount: Double(amount), category: response.result.category, priority: response.result.priority, groceries: response.result.groceries)
        return AIAnalysisResponse(result: result, source: response.source, notice: response.notice)
    }

    private func save() {
        isSaving = true
        do {
            let item = InboxItem(title: sourceText, type: "note", notes: sourceText)
            modelContext.insert(item)
            try InboxAnalysisPersistenceService.apply(editedResponse(), to: item, in: modelContext)
            message = "Saved in LifePilot."
            didSave = true
        } catch {
            message = "Couldn’t save this capture. Please try again."
            isSaving = false
        }
    }

    private func addToCalendar() {
        Swift.Task { @MainActor in
            do {
                let saved = try await eventKit.addCalendarEvent(title: title, date: dueDate, notes: notes)
                message = saved ? "Added to your Calendar." : "Calendar access is optional. Your appointment remains in LifePilot."
            } catch { message = "Calendar access is optional. Your appointment remains in LifePilot." }
        }
    }

    private func addReminder() {
        Swift.Task { @MainActor in
            do {
                let saved = try await eventKit.addReminder(title: title, dueDate: hasDueDate ? dueDate : nil, notes: notes)
                message = saved ? "Added to your Reminders." : "Reminder access is optional. This item remains in LifePilot."
            } catch { message = "Reminder access is optional. This item remains in LifePilot." }
        }
    }
}
