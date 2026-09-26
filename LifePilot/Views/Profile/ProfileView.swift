//
//  ProfileView.swift
//  LifePilot
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Your profile is coming soon",
                systemImage: "person",
                description: Text("Manage your preferences and personalize LifePilot here.")
            )
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
}
