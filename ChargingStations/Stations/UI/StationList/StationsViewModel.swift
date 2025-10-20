//
//  ContainerViewModel.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//
import Combine
import Foundation

final class StationsViewModel: ObservableObject {
    
    @Published var stations: [StationViewModel] = []
    @Published var lastUpdate: Date?
    
    private let stationsProvider: StationsProviderType
    private let respository: StationsRepositoryType
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(stationsProvider: StationsProviderType, respository: StationsRepositoryType) {
        self.stationsProvider = stationsProvider
        self.respository = respository
    }
    
    func startFetchingStations() {
        subscribeToUpdates()
    }
    
    private func subscribeToUpdates() {
        
        DefaultLogger.shared.info("Subscribe to station updates.")
        
        // Station updates
        DefaultLogger.shared.info("Subscribing to station updates.")
        self.stationsProvider.publishedStations
        .receive(on: DispatchQueue.main)
        .sink { [weak self] result in
            DefaultLogger.shared.info("Received stations fetch response.")
            
            switch result {
            case let .success(stations):
                DefaultLogger.shared.info("Received stations \(stations.count).")
                self?.stations = stations.map(StationViewModel.init)
            case let .failure(error):
                DefaultLogger.shared.info("Received stations fetch error: \(error).")
                // We could handle no network separately but in all cases it
                // would be good to show stations from cache
                self?.loadStationsFromCache(sortOption: .power)
            }
        }
        .store(in: &cancellables)
        
        DefaultLogger.shared.info("Assignes last update for updates.")
        stationsProvider.lastUpdatePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.lastUpdate, on: self)
            .store(in: &cancellables)
    }
    
    func endFetchingStations() {
        DefaultLogger.shared.info("End fetching stations.")
        stationsProvider.cancelUpdates()
        cancellables.removeAll()
    }
    
    private func loadStationsFromCache(sortOption: StationSortOption?) {
        DefaultLogger.shared.info("Loading stations from cache.")
        let lastUpdated = respository.lastUpdated
       
       respository.loadStations { [weak self] result in
           switch result {
               case .success(let stations):
               DispatchQueue.main.async {
                   DefaultLogger.shared.info("Loaded stations from cache.")
                   let sortedStations = sortOption?.apply(to: stations) ?? stations
                   self?.stations = sortedStations.map(StationViewModel.init)
                   self?.lastUpdate = lastUpdated
               }
               
           case .failure(let error):
               DefaultLogger.shared.error("Failed to load stations from cache \(error).")
               DispatchQueue.main.async {
                   self?.stations = []
                   self?.lastUpdate = nil
               }
           }
       }
    }
}
