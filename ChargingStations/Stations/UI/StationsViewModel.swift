//
//  ContainerViewModel.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//
import Combine
import Foundation
import CoreLocation

class StationsViewModel: ObservableObject {
    
    @Published var stations: [StationViewModel] = []
    @Published var currentLocation: CLLocation?
    @Published var lastUpdate: Date?
    
    private let stationsProvider: StationsProviderType
    private let locationManager: LocationManagerType
    
    private let boundingBoxCalculator = BoundingBoxCalculator()
    private let radiusInKm: Double = 1
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(stationsProvider: StationsProviderType, locationManager: LocationManagerType) {
        self.stationsProvider = stationsProvider
        self.locationManager = locationManager
    }
    
    func startFetchingStations() {
        subscribeToUpdates()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func subscribeToUpdates() {
        self.stationsProvider.publishedStations
        .receive(on: DispatchQueue.main)
        .sink { error in
            
        } receiveValue: { [weak self] stations in
            self?.stations = stations.map { StationViewModel(station: $0) }
            self?.lastUpdate = self?.stationsProvider.lastUpdate
        }
        .store(in: &cancellables)
        
        self.locationManager.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.updateLocation(location: location)
        }.store(in: &cancellables)
    }
    
    func endFetchingStations() {
        stationsProvider.cancelUpdates()
        locationManager.stopUpdatingLocation()
        cancellables.removeAll()
    }
    
    private func updateLocation(location: CLLocation?) {
        currentLocation = location
        
        stationsProvider.cancelUpdates()
        
        guard let coordinates = location?.coordinate else { return }
        
        // Calculate new boundingBox
        let boundingBox = boundingBoxCalculator.boundingBox(center: coordinates, radiusKm: radiusInKm)
        stationsProvider.startUpdates(for: boundingBox)
    }
}
