//
//  HomeView.swift
//  SeaShipTracker
//
//  Created by user on 19.07.2024.
//

import SwiftUI
import MapKit
import ClusterMap
import ClusterMapSwiftUI

struct ShipAnnotation: Identifiable, CoordinateIdentifiable, Hashable {
    let id = UUID()
    var name: String
    var type: ShipType = .tanker
    var iconName: String { "\(self.type.rawValue)_icon" }
    var coordinate: CLLocationCoordinate2D
    
    enum ShipType: String {
        case tanker, fishing, passenger, boat
    }
}

let ships = [
    ShipAnnotation(name: "Evergreen", type: .tanker, coordinate: CLLocationCoordinate2D(latitude: 51.501, longitude: -0.141)),
    ShipAnnotation(name: "EILTANK 49", type: .passenger, coordinate: CLLocationCoordinate2D(latitude: 51.508, longitude: -0.076))
]

let ships2 = [
    ShipAnnotation(name: "Evergreen", type: .tanker, coordinate: CLLocationCoordinate2D(latitude: 51.511, longitude: -0.151)),
    ShipAnnotation(name: "EILTANK 49", type: .passenger, coordinate: CLLocationCoordinate2D(latitude: 51.510, longitude: -0.08))
]

struct HomeView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var dataSource = DataSource()
    @State private var selectedTag: UUID?
    
    let timer = Timer.publish(every: 25, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        ZStack {
            Map(selection: $selectedTag) {
                ForEach(dataSource.annotations) { ship in
                    Annotation(ship.name, coordinate: ship.coordinate) {
                        ShipMarkerView(isTapped: $selectedTag, ship: ship)
                    }
                    .tag(ship.id)
                    .annotationTitles(.hidden)
                }
                ForEach(dataSource.clusters) { item in
                    Marker(
                        "\(item.count)",
                        systemImage: "square.3.layers.3d",
                        coordinate: item.coordinate
                    )
                }
            }
            .mapStyle(.hybrid(elevation: .realistic))
            .mapControls {
                MapUserLocationButton()
                MapPitchToggle()
                MapCompass()
            }
            .task {
                await dataSource.addAnnotations()
            }
            .onReceive(timer) { _ in
                Task.detached { await dataSource.updateAnnotations() }
            }
            .onAppear {
                locationManager.requestWhenInUseAuthorization()
            }
            .readSize(onChange: { newValue in
                dataSource.mapSize = newValue
            })
            .onMapCameraChange { context in
                dataSource.currentRegion = context.region
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                Task.detached { await dataSource.reloadAnnotations() }
            }
            .alertLocationPermission(isPresented: $locationManager.locationDenied) {
                locationManager.openSettings()
            }
            
            if let selectedTag, let ship = dataSource.annotations.first(where: { $0.id == selectedTag }) {
                ShipInfoMapView(selectedTag: $selectedTag, ship: ship)
                    .transition(.move(edge: .top))
                    .animation(.spring(), value: true)
            }
        }
    }
}

#Preview {
    HomeView()
}

extension HomeView {
    
    struct ClusterAnnotation: Identifiable {
        var id = UUID()
        var coordinate: CLLocationCoordinate2D
        var count: Int
    }
    
    @Observable
    final class DataSource: ObservableObject {
        private let clusterManager = ClusterManager<ShipAnnotation>()
        
        var annotations: [ShipAnnotation] = []
        var clusters: [ClusterAnnotation] = []
        
        var mapSize: CGSize = .zero
        var currentRegion: MKCoordinateRegion = LocationManager().userRegion ?? .sanFrancisco
        
        func addAnnotations() async {
            let newAnnotations = ships
            await clusterManager.add(newAnnotations)
            await reloadAnnotations()
        }
        
        func updateAnnotations() async {
            let newAnnotations = ships2
            await removeAnnotations()
            await clusterManager.add(newAnnotations)
            await reloadAnnotations()
        }
        
        func removeAnnotations() async {
            await clusterManager.removeAll()
            await reloadAnnotations()
        }
        
        func reloadAnnotations() async {
            async let changes = clusterManager.reload(mapViewSize: mapSize, coordinateRegion: currentRegion)
            await applyChanges(changes)
        }
        
        @MainActor
        private func applyChanges(_ difference: ClusterManager<ShipAnnotation>.Difference) {
            for removal in difference.removals {
                switch removal {
                case .annotation(let annotation):
                    annotations.removeAll { $0 == annotation }
                case .cluster(let clusterAnnotation):
                    clusters.removeAll { $0.id == clusterAnnotation.id }
                }
            }
            for insertion in difference.insertions {
                switch insertion {
                case .annotation(let newItem):
                    annotations.append(newItem)
                case .cluster(let newItem):
                    clusters.append(ClusterAnnotation(
                        id: newItem.id,
                        coordinate: newItem.coordinate,
                        count: newItem.memberAnnotations.count
                    ))
                }
            }
        }
    }
}


public extension MKCoordinateRegion {
    static var sanFrancisco: MKCoordinateRegion {
        .init(
            center: CLLocationCoordinate2D(latitude: 37.787_994, longitude: -122.407_437),
            span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    }
}


struct AsyncButton<Label: View>: View {
    @State private var isPerformingTask = false
    
    var action: () async -> Void
    @ViewBuilder var label: () -> Label
    
    var body: some View {
        Button(
            action: {
                isPerformingTask = true
                Task {
                    await action()
                    isPerformingTask = false
                }
            },
            label: {
                label().opacity(isPerformingTask ? 0.5 : 1)
            }
        )
        .disabled(isPerformingTask)
    }
}

extension AsyncButton where Label == Text {
    init(_ label: String, action: @escaping () async -> Void) {
        self.init(action: action) {
            Text(label)
        }
    }
}
