//
//  MapViewModel.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

import Foundation
import Combine
import MapKit
import _MapKit_SwiftUI

final class MapViewModel: ObservableObject {
    @Published var currentLocation: CLLocationCoordinate2D?

    @Published var mapCameraBounds: MapCameraBounds?
    
    @Published var chargingPoints: [StationCluster] = []
    @Published var lastUpdate: Date?
    
    @Published var selectedStationsText: String?
    @Published var emptyViewText: String = "No locations found."
    
    private let stationsProvider: StationsProviderType
    private static let radiusMeters: CLLocationDistance = 1000 // 1 km
    
    private let locationManager: LocationManagerType
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(stationsProvider: StationsProviderType, locationManager: LocationManagerType) {
        self.stationsProvider = stationsProvider
        self.locationManager = locationManager

        subscribeToUpdates()
    }
    
    private func subscribeToUpdates() {
        // Station updates
        DefaultLogger.shared.info("Subscribing to station updates.")
        self.stationsProvider.publishedStations
        .receive(on: DispatchQueue.main)
        .sink { [weak self] result in
            DefaultLogger.shared.info("Received fetch response.")
            
            switch result {
            case let .success(stations):
                self?.updateStationsOnMap(stations: stations)
            case let .failure(error):
                DefaultLogger.shared.info("Received stations fetch error: \(error).")
                self?.emptyViewText = error.localized
                // We could handle each error separately but for now just clearing the map
                self?.clearMap()
            }
        }
        .store(in: &cancellables)
        
        // Last updated date updates
        DefaultLogger.shared.info("Assigning last updated date updates.")
        stationsProvider.lastUpdatePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.lastUpdate, on: self)
            .store(in: &cancellables)
    }
    
    private func updateStationsOnMap(stations: [Station]) {
        guard let location = locationManager.currentLocation else {
            clearMap()
            return
        }
        
        self.currentLocation = location.coordinate
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: Self.radiusMeters, longitudinalMeters: Self.radiusMeters)
        self.mapCameraBounds = MapCameraBounds(centerCoordinateBounds: region)
        
        self.chargingPoints = clusterStationsIntoChargingPointsByLocation(stations: stations)
    }
    
    private func clearMap() {
        currentLocation = nil
        mapCameraBounds = nil
        chargingPoints.removeAll()
        lastUpdate = nil
    }
    
    private func clusterStationsIntoChargingPointsByLocation(
        stations: [Station],
        tolerance: Double = 0.0001
    ) -> [StationCluster] {
        
        var groups: [[StationViewModel]] = []
        
        for station in stations {
            if let index = groups.firstIndex(where: { group in
                group.contains { s in
                    abs(s.latitude - station.latitude) <= tolerance &&
                    abs(s.longitude - station.longitude) <= tolerance
                }
            }) {
                groups[index].append(StationViewModel(station: station))
            } else {
                groups.append([StationViewModel(station: station)])
            }
        }
        
        let cluster: [StationCluster] = groups.map { group in
            return StationCluster(
                clusterId: group.first?.id ?? UUID().uuidString,
                latitude: group.first?.latitude ?? 0,
                longitude: group.first?.longitude ?? 0,
                stations: group
            )
        }
        
        return cluster
    }

    // Compose short text to show available stations in one charging point / location
    public func showStations(for chargingPointId: String) {
        if let chargingPoints = chargingPoints.first(where: { $0.clusterId == chargingPointId }) {
            let sortedStations = chargingPoints.stations.sorted(by: { $0.id > $1.id} )
            
            var text: String = "\n"
            for stationIndex in 0..<sortedStations.count {
                text.append("Charging point \(stationIndex + 1):  \(sortedStations[stationIndex].availability.title)")
                text.append("\n")
            }
            selectedStationsText = text
        } else {
            selectedStationsText = nil
        }
    }
    
    public func hideStations() {
        selectedStationsText = nil
    }
}
