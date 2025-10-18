//
//  StationsProvider.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

import Foundation
import Combine

protocol StationsProviderType {
    func startUpdates(for boundingBox: BoundingBox)
    func cancelUpdates()
    var lastUpdate: Date? { get }
}

class StationsProvider {
    private let updateInterval: TimeInterval = 60
    private let respository: StationsRepositoryType
    private let client: StationFetching
    
    private var timer: Timer?
    
    private let stationsSubject: CurrentValueSubject<[Station], StationError> = .init([])
    var publishedStations: AnyPublisher<[Station], StationError> {
        stationsSubject.eraseToAnyPublisher()
    }
    private var cancellables: Set<AnyCancellable> = []
    
    init(repository: StationsRepositoryType, client: StationFetching) {
        self.respository = repository
        self.client = client
    }
    
    func startUpdates(for boundingBox: BoundingBox) {
        cancelUpdates()
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true, block: { [weak self] _ in
            self?.fetchStations(boundingBox: boundingBox)
        })
    }
    
    func cancelUpdates() {
        timer?.invalidate()
        timer = nil
    }
    
    var lastUpdate: Date? {
        respository.lastUpdated
    }
    
    private func fetchStations(boundingBox: BoundingBox) {
        client.fetchStations(boundingBox: boundingBox).sink { [weak self] result in
            switch result {
            case .failure(let error):
                if case StationError.networkUnavailable = error {
                    self?.sendStationsFromCache()
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
            self?.stationsSubject.send(stations)
        }.store(in: &cancellables)
    }
    
    private func saveStationsToCache(_ stations: [Station]) {
        respository.saveStations(stations, completion: {[weak self] result in
            switch result {
            case .success:
                self?.respository.saveLastUpdated(date: Date())
            case .failure(let error):
                // Log error
                break
            }
            
        })
    }
    
    private func sendStationsFromCache() {
        respository.loadStations { [weak self] result in
            switch result {
                case .success(let stations):
                self?.stationsSubject.send(stations)
            case .failure(let error):
                // log error
                break
            }
        }
    }
}
