//
//  StationsProvider.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

import Foundation
import Combine
import CoreLocation
import UIKit

protocol StationsProviderType {
    func cancelUpdates()
    var lastUpdatePublisher: AnyPublisher<Date?, Never> { get }
    var publishedStations: AnyPublisher<Result<[Station], StationError>, Never> { get }
}

final class StationsProvider: StationsProviderType {
    private var updateInterval: TimeInterval = 30
    
    private let respository: StationsRepositoryType
    private let locationManager: LocationManagerType
    private let client: StationFetching
    private let networkAvailability: ReachabilityMonitoring
    
    private let boundingBoxCalculator: BoundingBoxCalculator
    
    private var radiusInKm: Double = 1
    
    private var timer: Timer?
    
    private let stationsSubject: CurrentValueSubject<Result<[Station], StationError>, Never> = .init(Result<[Station], StationError>.success([]))
    var publishedStations: AnyPublisher<Result<[Station], StationError>, Never> {
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
         networkAvailability: ReachabilityMonitoring,
         radiusInKm: Double = 1,
         updateInterval: TimeInterval = 30,
         sortOption: StationSortOption? = .power) {
        self.respository = repository
        self.locationManager = locationManager
        self.client = client
        self.networkAvailability = networkAvailability
        self.radiusInKm = radiusInKm
        self.sortOption = sortOption
        self.boundingBoxCalculator = boundingBoxCalculator
        self.updateInterval = updateInterval
        
        startUpdates()
        startObservingLocation()
        startObservingNetworkAvailability()
        startObservingAppLifecycle()
    }
    
    deinit {
        cancellables.removeAll()
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
    
    private func startObservingNetworkAvailability() {
        DefaultLogger.shared.info("Start observing network.")
        
        networkAvailability.networkAvailablePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                DefaultLogger.shared.info("Network is available.")
                self?.startUpdates()
            }.store(in: &cancellables)
    }
    
    private func startObservingAppLifecycle() {
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                DefaultLogger.shared.info("App entered background")
                self?.cancelUpdates()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                DefaultLogger.shared.info("App will enter foreground")
                self?.startUpdates()
            }
            .store(in: &cancellables)
    }
    
    private func startUpdates(location: CLLocationCoordinate2D? = nil) {
        DefaultLogger.shared.info("Started station updates.")
        let currentLocation = location ?? locationManager.currentLocation?.coordinate
        
        cancelUpdates()

        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true, block: { [weak self] _ in
            if let location = currentLocation {
                DefaultLogger.shared.info("Fetching stations.")
                self?.fetchStations(location: location, sortOption: self?.sortOption)
            } else {
                DefaultLogger.shared.info("No location on fetching stations.")
                self?.stationsSubject.send(.failure(.locationUnavailable))
            }
        })
        timer?.fire()
    }
    
    func cancelUpdates() {
        timer?.invalidate()
        timer = nil
    }

    private func fetchStations(location: CLLocationCoordinate2D, sortOption: StationSortOption?) {
        let boundingBox = boundingBoxCalculator.boundingBox(center: location, radiusKm: radiusInKm)
        
        DefaultLogger.shared.info("Fetching stations from API.")
        
        client.fetchStations(boundingBox: boundingBox).sink { [weak self] result in
            switch result {
            case .failure(let error):
                self?.handleFaliureOnFetch(error: error)
            case .finished:
                DefaultLogger.shared.info("Finished fetching stations from API.")
                break
            }
        } receiveValue: { [weak self] apiStations in
            DefaultLogger.shared.info("Fetched stations from API: \(apiStations.count).")
            self?.handleFetchSuccess(apiStations: apiStations, location: location)
        }.store(in: &cancellables)
    }
    
    private func handleFetchSuccess(apiStations: [APIStation], location: CLLocationCoordinate2D) {
        DefaultLogger.shared.info("Fetched stations from API: \(apiStations.count).")
        let stations = apiStations.map { Station(apiStation: $0) }

        saveStationsToCache(stations, latitude: location.latitude, longitude: location.longitude)
        sendStations(stations: stations, sortOption: sortOption)
    }
    
    private func handleFaliureOnFetch(error: StationError) {
        if case StationError.networkUnavailable = error {
            DefaultLogger.shared.error("Network unavailable, fetching stations from cache.")
            stationsSubject.send(.failure(.networkUnavailable))
        } else {
            DefaultLogger.shared.error("Network error: \(error)")
            stationsSubject.send(.failure(.serviceUnavailable))
        }
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

    private func sendStations(stations: [Station], sortOption: StationSortOption?) {
        DefaultLogger.shared.info("Publishing stations.")
        if let sortedStations = sortOption?.apply(to: stations) {
            self.stationsSubject.send(.success(sortedStations))
        } else {
            self.stationsSubject.send(.success(stations))
        }
    }
    
    private func sendLastUpdate(date: Date?) {
        guard let date = date else { return }
        DefaultLogger.shared.info("Publishing last update date.")
        self.lastUpdateSubject.send(date)
    }
}
