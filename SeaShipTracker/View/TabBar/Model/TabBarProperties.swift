//
//  TabBarProperties.swift
//  SeaShipTracker
//
//  Created by user on 05.07.2024.
//

import Foundation

@Observable
class TabBarProperties {
    var activeTab: MenuType = .home
    var editMode: Bool = false
    var initialTabLocation: CGRect = .zero
    var movingTab: Int?
    var moveOfffset: CGSize = .zero
    var moveLocation: CGPoint = .zero
    var haptics: Bool = false
    var tabs: [TabBarModel] = {
        let order = SeaShipTrackerStorage.shared.tabBarOrder
        return defaultOrderTabs.sorted { (order.firstIndex(of: $0.id) ?? 0) < (order.firstIndex(of: $1.id) ?? 0) }
    }()
}
