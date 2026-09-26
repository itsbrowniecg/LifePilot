//
//  ContentView.swift
//  LifePilot
//
//  Created by Crystal Grace on 9/26/26.
//

import SwiftUI

struct ContentView: View {
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
    }
}

#Preview {
    ContentView()
}
