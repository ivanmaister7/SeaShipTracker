//
//  ShipInfoMapView.swift
//  SeaShipTracker
//
//  Created by user on 22.07.2024.
//

import SwiftUI

struct ShipInfoMapView: View {
    @Binding var selectedTag: UUID?
    let ship: ShipAnnotation
    
    var body: some View {
        VStack {
            HStack {
                Text(ship.name)
                    .padding()
                Spacer()
                Button(action: {
                    selectedTag = nil
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .background(Color.white)
            .cornerRadius(10)
            .padding()
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
