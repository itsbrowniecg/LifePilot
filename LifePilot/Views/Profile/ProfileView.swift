//
//  ProfileView.swift
//  LifePilot
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label("Alex", systemImage: "person.crop.circle")
                    Label("$50 weekly budget", systemImage: "dollarsign.circle")
                }

                Section {
                    Text("Profile preferences and personalization will appear here.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Profile")
        }
    }
}
