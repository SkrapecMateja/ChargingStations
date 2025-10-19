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
    @Published var currentLocation: CLLocationCoordinate2D = .init()

    @Published var mapCameraBounds: MapCameraBounds?
    
    @Published var chargingPoints: [ChargingPoint] = []
    @Published var lastUpdate: Date?
    
    @Published var selectedStationsText: String?
    
    private let stationsProvider: StationsProviderType
    private static let radiusMeters: CLLocationDistance = 000
    
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
            .sink { [weak self] location in
                guard let coordinates = location?.coordinate else { return }
                
                self?.currentLocation = coordinates
                
                let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: Self.radiusMeters, longitudinalMeters: Self.radiusMeters)
                self?.mapCameraBounds = MapCameraBounds(centerCoordinateBounds: region)
                
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
    
    public func showStations(for chargingPointId: String) {
        if let chargingPoints = chargingPoints.first(where: { $0.stationId == chargingPointId }) {
            let sortedStations = chargingPoints.stations.sorted(by: { $0.id > $1.id} )
            
            var text: String = "\n"
            for stationIndex in 0..<sortedStations.count {
                text.append("Charging point \(stationIndex + 1): \(sortedStations[stationIndex].availability.title)")
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
