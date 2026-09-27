import EventKit

@MainActor
final class EventKitService {
    private let store = EKEventStore()

    func addCalendarEvent(title: String, date: Date, notes: String?) async throws -> Bool {
        guard try await calendarAccessGranted() else { return false }
        guard let calendar = store.defaultCalendarForNewEvents else { return false }
        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = date
        event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: date) ?? date
        event.notes = notes
        event.calendar = calendar
        try store.save(event, span: .thisEvent)
        return true
    }

    func addReminder(title: String, dueDate: Date?, notes: String?) async throws -> Bool {
        guard try await reminderAccessGranted() else { return false }
        guard let calendar = store.defaultCalendarForNewReminders() else { return false }
        let reminder = EKReminder(eventStore: store)
        reminder.title = title
        reminder.notes = notes
        reminder.calendar = calendar
        if let dueDate {
            reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        }
        try store.save(reminder, commit: true)
        return true
    }

    private func calendarAccessGranted() async throws -> Bool {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .fullAccess, .authorized: return true
        case .notDetermined: return try await store.requestFullAccessToEvents()
        default: return false
        }
    }

    private func reminderAccessGranted() async throws -> Bool {
        switch EKEventStore.authorizationStatus(for: .reminder) {
        case .fullAccess, .authorized: return true
        case .notDetermined: return try await store.requestFullAccessToReminders()
        default: return false
        }
    }
}
