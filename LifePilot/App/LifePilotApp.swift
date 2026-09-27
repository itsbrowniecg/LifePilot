//
//  LifePilotApp.swift
//  LifePilot
//
//  Created by Crystal Grace on 9/26/26.
//

import SwiftUI
import SwiftData

@main
struct LifePilotApp: App {
    private let aiService: any AIServiceProtocol = AIServiceFactory.makeService()
    private let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Task.self,
            Bill.self,
            Grocery.self,
            Appointment.self,
            InboxItem.self
        ])

        do {
            return try ModelContainer(for: schema)
        } catch {
            fatalError("Unable to create LifePilot's model container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(aiService: aiService)
        }
        .modelContainer(sharedModelContainer)
    }
}
