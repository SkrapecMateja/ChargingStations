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

struct ChargingPoint: Identifiable {
    let stationId: String
    let latitude: Double
    let longitude: Double
    
    var bestAvailability: Availability {
        stations.map(\.availability).max() ?? .unknown
    }
    
    var id: String { stationId }
    
    let stations: [StationViewModel]
}

class MapViewModel: ObservableObject {
    @Published var currentLocation: CLLocationCoordinate2D = .init() {
        didSet {
            mapCameraBounds = MapCameraBounds(
                centerCoordinateBounds: MKMapRect(
                    origin: MKMapPoint(currentLocation),
                    size: MKMapSize(width: radiusMeters, height: radiusMeters)
                ),
                minimumDistance: radiusMeters,
                maximumDistance: radiusMeters
            )
        }
    }
    @Published var mapCameraBounds: MapCameraBounds?
    
    @Published var chargingPoints: [ChargingPoint] = []
    @Published var lastUpdate: Date?
    
    private let stationsProvider: StationsProviderType
    private let radiusMeters: CLLocationDistance = 10000
    
    private let locationManager: LocationManagerType
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(stationsProvider: StationsProviderType, locationManager: LocationManagerType) {
        self.stationsProvider = stationsProvider
        self.locationManager = locationManager

        subscribeToUpdates()
    }
    
    private func subscribeToUpdates() {
        self.stationsProvider.publishedStations
        .receive(on: DispatchQueue.main)
        .sink { error in
            
        } receiveValue: { [weak self] stations in
            self?.chargingPoints = self?.groupStationsByChargingPoint(stations: stations) ?? []
        }
        .store(in: &cancellables)
        
        stationsProvider.lastUpdatePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.lastUpdate, on: self)
            .store(in: &cancellables)
        
        locationManager.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { location in
                if let location = location {
                    self.currentLocation = location.coordinate
                }
            }.store(in: &cancellables)
    }
    
    private func groupStationsByChargingPoint(stations: [Station]) -> [ChargingPoint] {
        let stationVMs = stations.map { StationViewModel(station: $0) }
        let groupedByChargingPoint = Dictionary(grouping: stationVMs, by: \.chargingStationId)
        
        let chargingPoints: [ChargingPoint] = groupedByChargingPoint.map { (stationId, stations) in
            ChargingPoint(
                stationId: stationId,
                latitude: stations.first?.latitude ?? 0,
                longitude: stations.first?.longitude ?? 0,
                stations: stations
            )
        }
        
        return chargingPoints
    }
}
