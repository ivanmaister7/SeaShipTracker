//
//  ShipView.swift
//  SeaShipTracker
//
//  Created by user on 22.07.2024.
//

import SwiftUI

struct ShipMarkerView: View {
    @Binding var isTapped: UUID?
    let ship: ShipAnnotation

    var body: some View {
        VStack {
            Image(ship.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .shadow(radius: 10)
            Text(ship.name)
                .font(.system(size: 13))
                .fontWeight(.bold)
                .frame(width: 150)
                .foregroundColor(.white)
                .shadow(color: .black, radius: 1, x: 1, y: 1)
                .padding(.top, -15)
        }
        .padding(30) // Add padding around the content to ensure it fits within the circle
        .background(isTapped == ship.id ? Color.blue.opacity(0.4) : Color.clear)
        .clipShape(Circle())
        .shadow(radius: isTapped == ship.id ? 10 : 0)
    }
}

//struct ShipView_Previews: PreviewProvider {
//    static var previews: some View {
//        ShipView(shipImage: "tanker_icon", shipName: "Ship Name dfdfdf dfdfdf dfdf")
//    }
//}

