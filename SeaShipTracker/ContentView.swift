//
//  ContentView.swift
//  SeaShipTracker
//
//  Created by user on 05.07.2024.
//

import SwiftUI

struct ContentView: View {
    var properties: TabBarProperties = .init()
    var body: some View {
        @Bindable var bindings = properties
        ZStack {
            //tab bar logic
            TabView(selection: $bindings.activeTab) {
                HomeView()
                    .tag(MenuType.home)
                    .hideTabBar()
                SearchView()
                    .tag(MenuType.search)
                    .hideTabBar()
                NotificationView()
                    .tag(MenuType.notification)
                    .hideTabBar()
                Settings()
                    .environment(properties)
                    .tag(MenuType.settings)
                    .hideTabBar()
            }
            
            //tab bar visual
            VStack {
                Spacer()
                DragableTabBar()
                    .frame(height: 40)
                    .environment(properties)
            }
        }
    }
}

#Preview {
    ContentView()
}
