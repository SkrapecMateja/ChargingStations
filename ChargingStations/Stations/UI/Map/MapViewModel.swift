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
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

class MapViewModel: ObservableObject {
    @Published var currentLocation: CLLocationCoordinate2D?

    @Published var mapCameraBounds: MapCameraBounds?
    
    @Published var chargingPoints: [ChargingPoint] = []
    @Published var lastUpdate: Date?
    
    @Published var selectedStationsText: String?
    
    private let stationsProvider: StationsProviderType
    private static let radiusMeters: CLLocationDistance = 1000
    
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
        .sink { [weak self] stations in
            DefaultLogger.shared.info("Received stations \(stations.count).")
            self?.chargingPoints = self?.groupStationsByChargingPoint(stations: stations) ?? []
        }
        .store(in: &cancellables)
        
        // Last updated date updates
        DefaultLogger.shared.info("Assigning last updated date updates.")
        stationsProvider.lastUpdatePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.lastUpdate, on: self)
            .store(in: &cancellables)
        
        // Location updates
        DefaultLogger.shared.info("Subscribing to location updates.")
        locationManager.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                DefaultLogger.shared.info("Received location updates.")
                guard let coordinate = location?.coordinate else {
                    self?.clearMap()
                    return
                }
                
                self?.currentLocation = coordinate
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: Self.radiusMeters, longitudinalMeters: Self.radiusMeters)
                self?.mapCameraBounds = MapCameraBounds(centerCoordinateBounds: region)
                
            }.store(in: &cancellables)
    }
    
    private func clearMap() {
        currentLocation = nil
        mapCameraBounds = nil
        chargingPoints.removeAll()
        lastUpdate = nil
    }
    
    private func groupStationsByChargingPoint(stations: [Station]) -> [ChargingPoint] {
        DefaultLogger.shared.info("Groupping stations by location / charging point.")
        
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
    
    // Short method to show available stations in one charging point / location
    public func showStations(for chargingPointId: String) {
        if let chargingPoints = chargingPoints.first(where: { $0.stationId == chargingPointId }) {
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
