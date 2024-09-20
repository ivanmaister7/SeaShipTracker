//
//  File.swift
//  SeaShipTracker
//
//  Created by user on 19.07.2024.
//
import SwiftUI

class SeaShipTrackerStorage {
    private init() {}
    static let shared = SeaShipTrackerStorage()
    
    @AppStorage("TabBarOrder") var tabBarOrder: [Int] = []
}
