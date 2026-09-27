//
//  ContentView.swift
//  LifePilot
//
//  Created by Crystal Grace on 9/26/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            InboxView()
                .tabItem {
                    Label("Inbox", systemImage: "tray")
                }

            TasksView()
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }

            PantryView()
                .tabItem {
                    Label("Pantry", systemImage: "cabinet")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .task {
            DemoDataService.seedIfNeeded(in: modelContext)
        }
    }
}
