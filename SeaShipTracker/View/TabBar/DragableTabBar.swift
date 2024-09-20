//
//  DragableTabBar.swift
//  SeaShipTracker
//
//  Created by user on 05.07.2024.
//

import SwiftUI

struct DragableTabBar: View {
    @Environment (TabBarProperties.self) private var properties
    var body: some View {
        @Bindable var binding = properties
        HStack(spacing: 0) {
            ForEach($binding.tabs) { $tab in
                TabBarButton(tab: $tab)
            }
        }
        .padding (.horizontal, 10)
        .background(.bar)
        .overlay(alignment: .topLeading) {
            if let id = properties.movingTab,
               let tab = properties.tabs.first(where: { $0.id == id }) {
                Image(systemName: tab.symbolImage)
                    .font(.title2)
                    .offset(x: properties.initialTabLocation.minX,
                            y: properties.initialTabLocation.minY)
                    .offset(properties.moveOfffset)
            }
        }
        .coordinateSpace(name: "VIEW")
        .onChange(of: properties.moveLocation) { oldValue, newValue in
            if let droppingIndex = properties.tabs.firstIndex(where: { $0.rect.contains(newValue)}),
               let activeIndex = properties.tabs.firstIndex(where: { $0.id == properties.movingTab}),
               droppingIndex != activeIndex {
                withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                    (properties.tabs[droppingIndex].id, properties.tabs[activeIndex].id) =
                    (properties.tabs[activeIndex].id, properties.tabs[droppingIndex].id)
                    (properties.tabs[droppingIndex].symbolImage, properties.tabs[activeIndex].symbolImage) =
                    (properties.tabs[activeIndex].symbolImage, properties.tabs[droppingIndex].symbolImage)
                    (properties.tabs[droppingIndex].tabTitle, properties.tabs[activeIndex].tabTitle) =
                    (properties.tabs[activeIndex].tabTitle, properties.tabs[droppingIndex].tabTitle)
                }
                
                saveTabBarOrder()
            }
        }
        .sensoryFeedback(.success, trigger: properties.haptics)
    }
    
    private func saveTabBarOrder() {
        let order: [Int] = properties.tabs.reduce([]) { partResult, model in
            return partResult + [model.id]
        }
        
        SeaShipTrackerStorage.shared.tabBarOrder = order
    }
}

/// Tab Bar Bútton
struct TabBarButton: View {
    @Binding var tab: TabBarModel
    @Environment (TabBarProperties.self) private var properties
    @State private var tabRect: CGRect = .zero
    @State private var currentId: Int = -1
    
    var body: some View {
        @Bindable var binding = properties
        
        VStack(spacing: 4) {
            Image (systemName: tab.symbolImage)
                .symbolEffect(.bounce.down.byLayer, value: tab.isAnimating)
            Text(tab.tabTitle)
                .font(.caption2)
                .textScale(.secondary)
            //remove this modifier for visibility tab title while editing
                .foregroundStyle(properties.editMode ? .clear :
                                    properties.activeTab == tab.type ? .primary : .secondary)
        }
        .font(.title2)
        .symbolEffect(.bounce.down.byLayer, value: tab.isAnimating)
        .background(GeometryReader { proxy in
            Color.clear.onAppear {
                tabRect = proxy.frame(in: .named("VIEW"))
                tab.tabRect = tabRect
            }
        })
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .foregroundStyle(properties.activeTab == tab.type ? .primary : properties.editMode ? .primary : .secondary)
        .opacity(properties.movingTab == tab.id ? 0 : 1)
        .overlay {
            if !properties.editMode {
                Rectangle()
                    .foregroundColor(.clear)
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.bouncy, completionCriteria: .logicallyComplete, {
                            properties.activeTab = tab.type
                            tab.isAnimating = true
                        }, completion: {
                            var transaction = Transaction()
                            transaction.disablesAnimations = true
                            withTransaction(transaction) {
                                tab.isAnimating = nil
                            }
                        })
                    }
            } else {
                Rectangle()
                    .foregroundColor(.clear)
                    .contentShape(.rect)
                    .background(CustomGesture(isEnabled: $binding.editMode, trigger: { status in
                        if status {
                            currentId = tab.id
                            properties.initialTabLocation = tab.tabRect
                            properties.movingTab = tab.id
                        } else {
                            withAnimation(.easeInOut(duration: 0.3),
                                          completionCriteria: .logicallyComplete) {
                                let indexOfFrameOfTriggeredButton = properties.tabs.firstIndex(where: { $0.id == currentId}) ?? tab.id
                                properties.initialTabLocation = properties.tabs[indexOfFrameOfTriggeredButton].tabRect
                                properties.moveOfffset = .zero
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    properties.editMode = false
                                    DispatchQueue.main.async {
                                        properties.editMode = true
                                    }
                                }
                            } completion: {
                                properties.moveLocation = .zero
                                properties.movingTab = nil
                            }
                        }
                    }, onChanged: { newOffset, newLocation in
                        properties.moveOfffset = newOffset
                        properties.moveLocation = newLocation
                    }))
            }
        }
        .loopingWiggle(properties.editMode)
        .background(GeometryReader { proxy in
            Color.clear.onAppear {
                tab.rect = proxy.frame(in: .global)
            }
        })
    }
}

#Preview {
    ContentView()
}
