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
    var publishedStations: AnyPublisher<[Station], Never> { get }
}

class StationsProvider: StationsProviderType {
    private let updateInterval: TimeInterval = 10
    
    private let respository: StationsRepositoryType
    private let locationManager: LocationManagerType
    private let client: StationFetching
    
    private let boundingBoxCalculator: BoundingBoxCalculator
    
    private var radiusInKm: Double = 1
    
    private var timer: Timer?
    
    private let stationsSubject: CurrentValueSubject<[Station], Never> = .init([])
    var publishedStations: AnyPublisher<[Station], Never> {
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
        DefaultLogger.shared.info("Start observing location.")
        
        self.locationManager.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                if let location = location {
                    DefaultLogger.shared.info("Received location update.")
                    self?.startUpdates(location: location.coordinate)
                }
        }.store(in: &cancellables)
    }
    
    private func startUpdates(location: CLLocationCoordinate2D? = nil) {
        DefaultLogger.shared.info("Started station updates.")
        
        cancelUpdates()

        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true, block: { [weak self] _ in
            if let location = location {
                self?.fetchStations(location: location, sortOption: self?.sortOption)
            } else {
                self?.sendStationsFromCache(sortOption: self?.sortOption)
            }
        })
        timer?.fire()
    }
    
    func cancelUpdates() {
        timer?.invalidate()
        timer = nil
        cancellables.removeAll()
    }

    private func fetchStations(location: CLLocationCoordinate2D, sortOption: StationSortOption?) {
        let boundingBox = boundingBoxCalculator.boundingBox(center: location, radiusKm: radiusInKm)
        
        DefaultLogger.shared.info("Fetching stations from API.")
        
        client.fetchStations(boundingBox: boundingBox).sink { [weak self] result in
            switch result {
            case .failure(let error):
                if case StationError.networkUnavailable = error {
                    DefaultLogger.shared.error("Network unavailable, fetching stations from cache.")
                    self?.sendStationsFromCache(sortOption: sortOption)
                } else {
                    DefaultLogger.shared.error("Network error: \(error)")
                }
            case .finished:
                DefaultLogger.shared.info("Finished fetching stations from API.")
                break
            }
        } receiveValue: { [weak self] apiStations in
            DefaultLogger.shared.info("Fetched stations from API: \(apiStations.count).")
            let stations = apiStations.map { Station(apiStation: $0) }

            self?.saveStationsToCache(stations, latitude: location.latitude, longitude: location.longitude)
            self?.sendStations(stations: stations, sortOption: sortOption)
        }.store(in: &cancellables)
    }
    
    private func saveStationsToCache(_ stations: [Station], latitude: Double, longitude: Double) {
        DefaultLogger.shared.info("Saving stations to cache.")
        respository.saveStations(stations, completion: {[weak self] result in
            switch result {
            case .success:
                let date = Date()
                DefaultLogger.shared.info("Saving last updated date and location to cache after succesful stations save.")
                self?.respository.saveLastUpdated(date: date)
                self?.sendLastUpdate(date: date)
            case .failure(let error):
                DefaultLogger.shared.error("Failed to save stations to cache \(error).")
                break
            }
        })
    }
    
    private func sendStationsFromCache(sortOption: StationSortOption?) {
        let lastUpdated = respository.lastUpdated
        
        DefaultLogger.shared.info("Loading stations from cache.")
        
        respository.loadStations { [weak self] result in
            switch result {
                case .success(let stations):
                self?.sendStations(stations: stations, sortOption: sortOption)
                self?.sendLastUpdate(date: lastUpdated)
            case .failure(let error):
                DefaultLogger.shared.error("Failed to load stations from cache \(error).")
                break
            }
        }
    }
    
    private func sendStations(stations: [Station], sortOption: StationSortOption?) {
        DefaultLogger.shared.info("Publishing stations.")
        if let sortedStations = sortOption?.apply(to: stations) {
            self.stationsSubject.send(sortedStations)
        } else {
            self.stationsSubject.send(stations)
        }
    }
    
    private func sendLastUpdate(date: Date?) {
        guard let date = date else { return }
        DefaultLogger.shared.info("Publishing last update date.")
        self.lastUpdateSubject.send(date)
    }
}
