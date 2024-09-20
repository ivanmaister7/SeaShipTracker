//
//  View_Extension.swift
//  SeaShipTracker
//
//  Created by user on 05.07.2024.
//

import SwiftUI

extension View {
    @ViewBuilder
    func hideTabBar() -> some View {
        self.toolbar(.hidden, for: .tabBar)
    }
    
    @ViewBuilder
    func loopingWiggle(_ isEnabled: Bool = false) -> some View {
        self.symbolEffect(.pulse, isActive: isEnabled)
    }
    
    public func alertLocationPermission(isPresented: Binding<Bool>, action: @escaping () -> () = {}) -> some View {
        self
            .alert(isPresented: isPresented) {
                Alert(
                    title: Text("Location Permission Denied"),
                    message: Text("To re-enable, please go to Settings and turn on Location Services for this app."),
                    primaryButton: .default(Text("Open Settings")) {
                        action()
                    },
                    secondaryButton: .cancel()
                )
            }
    }
}
