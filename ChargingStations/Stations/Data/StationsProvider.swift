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
}

class StationsProvider: StationsProviderType {
    private let updateInterval: TimeInterval = 10
    
    private let respository: StationsRepositoryType
    private let locationManager: LocationManagerType
    private let client: StationFetching
    
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
         radiusInKm: Double = 1,
         sortOption: StationSortOption? = nil) {
        self.respository = repository
        self.locationManager = locationManager
        self.client = client
        self.radiusInKm = radiusInKm
        self.sortOption = sortOption
        
        startObservingLocation()
    }
    
    private func startObservingLocation() {
        self.locationManager.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                if let location = location {
                    self?.startUpdates(location: location)
                }
        }.store(in: &cancellables)
    }
    
    private func startUpdates(location: CLLocation) {
        cancelUpdates()

        guard let boundingBox = locationManager.boundingBoxFromCurrentLocation(withDistance: radiusInKm) else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true, block: { [weak self] _ in
            self?.fetchStations(boundingBox: boundingBox, sortOption: self?.sortOption)
        })
        timer?.fire()
    }
    
    func cancelUpdates() {
        timer?.invalidate()
        timer = nil
        cancellables.removeAll()
    }

    private func fetchStations(boundingBox: BoundingBox, sortOption: StationSortOption?) {
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
            self?.saveStationsToCache(stations)
            self?.sendStations(stations: stations, sortOption: sortOption)
        }.store(in: &cancellables)
    }
    
    private func saveStationsToCache(_ stations: [Station]) {
        respository.saveStations(stations, completion: {[weak self] result in
            switch result {
            case .success:
                let date = Date()
                self?.respository.saveLastUpdated(date: date)
                self?.lastUpdateSubject.send(date)
            case .failure(let error):
                // Log error
                break
            }
            
        })
    }
    
    private func sendStationsFromCache(sortOption: StationSortOption?) {
        respository.loadStations { [weak self] result in
            switch result {
                case .success(let stations):
                self?.sendStations(stations: stations, sortOption: sortOption)
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
}
