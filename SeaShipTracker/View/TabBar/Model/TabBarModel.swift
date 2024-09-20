//
//  TabBarModel.swift
//  SeaShipTracker
//
//  Created by user on 05.07.2024.
//

import Foundation

struct TabBarModel: Identifiable {
    var id: Int
    var type: MenuType { return MenuType(id) }
    var symbolImage: String
    var tabTitle: String
    //for dragging
    var rect: CGRect = .zero
    var tabRect: CGRect = .zero
    //for animation
    var isAnimating: Bool?
}

enum MenuType {
    case home, search, notification, settings
    
    init(_ value: Int) {
        switch value {
        case 0: self = .home
        case 1: self = .search
        case 2: self = .notification
        case 3: self = .settings
        default: self = .home
        }
    }
}

let defaultOrderTabs: [TabBarModel] = [
    .init(id: 0, symbolImage: "house.fill", tabTitle: "Home"),
    .init(id: 1, symbolImage: "magnifyingglass", tabTitle: "Search"),
    .init(id: 2, symbolImage: "bell.fill", tabTitle: "Notifications"),
    .init(id: 3, symbolImage: "gearshape.fill", tabTitle: "Settings")
//    .init(id: 4, symbolImage: "gearshape.fill", tabTitle: "")
]
