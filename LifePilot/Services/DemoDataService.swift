//
//  DemoDataService.swift
//  LifePilot
//

import Foundation
import SwiftData

enum DemoDataService {
    static func seedIfNeeded(in modelContext: ModelContext) {
        guard databaseIsEmpty(in: modelContext) else {
            backfillDemoGroceryCategories(in: modelContext)
            return
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let tonight = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: today) ?? today
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let twoDaysFromNow = calendar.date(byAdding: .day, value: 2, to: today) ?? today
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: today) ?? today
        let nextMonth = calendar.date(byAdding: .day, value: 30, to: today) ?? today
        let appointmentTime = calendar.date(bySettingHour: 16, minute: 0, second: 0, of: today) ?? today

        modelContext.insert(Task(title: "Finish CS assignment", notes: "Submit the final assignment.", dueDate: tonight))
        modelContext.insert(Task(title: "Buy detergent", notes: "Pick up detergent for laundry.", dueDate: twoDaysFromNow))

        modelContext.insert(Bill(title: "Electricity bill", amount: 83.42, dueDate: tomorrow, category: "Utilities"))

        modelContext.insert(Grocery(name: "Eggs", expirationDate: nextWeek, quantity: 12, category: GroceryCategory.protein.rawValue))
        modelContext.insert(Grocery(name: "Chicken", expirationDate: twoDaysFromNow, quantity: 1, category: GroceryCategory.protein.rawValue))
        modelContext.insert(Grocery(name: "Rice", expirationDate: nextMonth, quantity: 1, category: GroceryCategory.carbs.rawValue))
        modelContext.insert(Grocery(name: "Spinach", expirationDate: today, quantity: 1, category: GroceryCategory.plants.rawValue))
        modelContext.insert(Grocery(name: "Bread", expirationDate: nextWeek, quantity: 1, category: GroceryCategory.carbs.rawValue))
        modelContext.insert(Grocery(name: "Milk", expirationDate: twoDaysFromNow, quantity: 1, category: GroceryCategory.dairy.rawValue))

        modelContext.insert(Appointment(title: "Doctor appointment", date: appointmentTime, location: "City Medical Center"))

        modelContext.insert(InboxItem(title: "Electricity bill", type: "Bill", notes: "Monthly utility statement."))
        modelContext.insert(InboxItem(title: "CS assignment", type: "Task", notes: "Assignment details from class."))
        modelContext.insert(InboxItem(title: "Grocery receipt", type: "Receipt", notes: "Recent grocery purchase."))

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Unable to save demo data: \(error)")
        }
    }

    private static func databaseIsEmpty(in modelContext: ModelContext) -> Bool {
        let taskCount = (try? modelContext.fetchCount(FetchDescriptor<Task>())) ?? 0
        let billCount = (try? modelContext.fetchCount(FetchDescriptor<Bill>())) ?? 0
        let groceryCount = (try? modelContext.fetchCount(FetchDescriptor<Grocery>())) ?? 0
        let appointmentCount = (try? modelContext.fetchCount(FetchDescriptor<Appointment>())) ?? 0
        let inboxItemCount = (try? modelContext.fetchCount(FetchDescriptor<InboxItem>())) ?? 0

        return taskCount + billCount + groceryCount + appointmentCount + inboxItemCount == 0
    }

    private static func backfillDemoGroceryCategories(in modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Grocery>()
        guard let groceries = try? modelContext.fetch(descriptor) else { return }

        var didUpdate = false
        for grocery in groceries where grocery.category == GroceryCategory.other.rawValue {
            guard let category = demoGroceryCategory(for: grocery.name) else { continue }
            grocery.category = category.rawValue
            didUpdate = true
        }

        guard didUpdate else { return }
        do {
            try modelContext.save()
        } catch {
            assertionFailure("Unable to update demo grocery categories: \(error)")
        }
    }

    private static func demoGroceryCategory(for name: String) -> GroceryCategory? {
        switch name.lowercased() {
        case "eggs", "chicken": .protein
        case "rice", "bread": .carbs
        case "spinach": .plants
        case "milk": .dairy
        default: nil
        }
    }
}
