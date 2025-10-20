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
    
    @Published var isLoading: Bool = false
    
    private let stationsProvider: StationsProviderType
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(stationsProvider: StationsProviderType) {
        self.stationsProvider = stationsProvider
    }
    
    func startFetchingStations() {
        isLoading = true
        subscribeToUpdates()
    }
    
    private func subscribeToUpdates() {
        
        DefaultLogger.shared.info("Subscribe to station updates.")
        
        self.stationsProvider.publishedStations
        .receive(on: DispatchQueue.main)
        .sink { [weak self] stations in
            self?.stations = stations.map { StationViewModel(station: $0) }
            self?.isLoading = false
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
        isLoading = false
    }
}
