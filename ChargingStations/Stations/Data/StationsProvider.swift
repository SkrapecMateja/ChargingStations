//
//  StationsProvider.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

import Foundation
import Combine
import CoreLocation

protocol StationsProviderType {
    func cancelUpdates()
    var lastUpdatePublisher: AnyPublisher<Date?, Never> { get }
    var publishedStations: AnyPublisher<[Station], StationError> { get }
    func resolveLocation(location: CLLocationCoordinate2D?) -> CLLocationCoordinate2D?
}

class StationsProvider: StationsProviderType {
    private let updateInterval: TimeInterval = 10
    
    private let respository: StationsRepositoryType
    private let locationManager: LocationManagerType
    private let client: StationFetching
    
    private let boundingBoxCalculator: BoundingBoxCalculator
    
    private var radiusInKm: Double = 1
    
    private var timer: Timer?
    
    private let stationsSubject: CurrentValueSubject<[Station], StationError> = .init([])
    var publishedStations: AnyPublisher<[Station], StationError> {
        stationsSubject.eraseToAnyPublisher()
    }
    
    private let lastUpdateSubject: CurrentValueSubject<Date?, Never> = .init(nil)
    var lastUpdatePublisher: AnyPublisher<Date?, Never> {
        lastUpdateSubject.eraseToAnyPublisher()
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var sortOption: StationSortOption?
    
    init(repository: StationsRepositoryType,
         locationManager: LocationManagerType,
         client: StationFetching,
         boundingBoxCalculator: BoundingBoxCalculator = BoundingBoxCalculator(),
         radiusInKm: Double = 1,
         sortOption: StationSortOption? = nil) {
        self.respository = repository
        self.locationManager = locationManager
        self.client = client
        self.radiusInKm = radiusInKm
        self.sortOption = sortOption
        self.boundingBoxCalculator = boundingBoxCalculator
        
        startUpdates()
        startObservingLocation()
    }
    
    private func startObservingLocation() {
        self.locationManager.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                if let location = location {
                    self?.startUpdates(location: location.coordinate)
                }
        }.store(in: &cancellables)
    }
    
    private func startUpdates(location: CLLocationCoordinate2D? = nil) {
        cancelUpdates()
        
        let currentLocation = resolveLocation(location: location) // If in airplane mode and no location, get last known location from cache
        
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true, block: { [weak self] _ in
            if let location = currentLocation {
                self?.fetchStations(location: location, sortOption: self?.sortOption)
            }
            
        })
        timer?.fire()
    }
    
    func cancelUpdates() {
        timer?.invalidate()
        timer = nil
        cancellables.removeAll()
    }
    
    func resolveLocation(location: CLLocationCoordinate2D?) -> CLLocationCoordinate2D? {
        var currentLocation: CLLocationCoordinate2D? = location
        if currentLocation == nil, let latitude = respository.lastLocationLatitude, let longitude = respository.lastLocationLongitude {
            // Load last known location
            currentLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return currentLocation
    }

    private func fetchStations(location: CLLocationCoordinate2D, sortOption: StationSortOption?) {
        let boundingBox = boundingBoxCalculator.boundingBox(center: location, radiusKm: radiusInKm)
        
        client.fetchStations(boundingBox: boundingBox).sink { [weak self] result in
            switch result {
            case .failure(let error):
                if case StationError.networkUnavailable = error {
                    self?.sendStationsFromCache(sortOption: sortOption)
                } else {
                    self?.stationsSubject.send(completion: .failure(error))
                }
            case .finished:
                //Log error
                break
            }
        } receiveValue: { [weak self] apiStations in
            let stations = apiStations.map { Station(apiStation: $0) }
            self?.saveStationsToCache(stations, latitude: location.latitude, longitude: location.longitude)
            self?.sendStations(stations: stations, sortOption: sortOption)
        }.store(in: &cancellables)
    }
    
    private func saveStationsToCache(_ stations: [Station], latitude: Double, longitude: Double) {
        respository.saveStations(stations, completion: {[weak self] result in
            switch result {
            case .success:
                let date = Date()
                self?.respository.saveLastUpdated(date: date)
                self?.respository.saveLastLocation(longitude: longitude, latitude: latitude)
                self?.sendLastUpdate(date: date)
            case .failure(let error):
                // Log error
                break
            }
        })
    }
    
    private func sendStationsFromCache(sortOption: StationSortOption?) {
        let lastUpdated = respository.lastUpdated
        
        respository.loadStations { [weak self] result in
            switch result {
                case .success(let stations):
                self?.sendStations(stations: stations, sortOption: sortOption)
                self?.sendLastUpdate(date: lastUpdated)
            case .failure(let error):
                // log error
                break
            }
        }
    }
    
    private func sendStations(stations: [Station], sortOption: StationSortOption?) {
        if let sortedStations = sortOption?.apply(to: stations) {
            self.stationsSubject.send(sortedStations)
        } else {
            self.stationsSubject.send(stations)
        }
    }
    
    private func sendLastUpdate(date: Date?) {
        guard let date = date else { return }
        self.lastUpdateSubject.send(date)
    }
}
