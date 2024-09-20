//
//  Home.swift
//  SeaShipTracker
//
//  Created by user on 05.07.2024.
//

import SwiftUI

struct Settings: View {
    @Environment (TabBarProperties.self) private var properties
    var body: some View {
        @Bindable var binding = properties
        NavigationStack {
            List {
                Toggle("Edit TabBar", isOn: $binding.editMode)
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    ContentView()
}
