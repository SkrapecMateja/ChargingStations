//
//  ContainerViewModel.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//
import Combine
import Foundation

class StationsViewModel: ObservableObject {
    
    @Published var stations: [StationViewModel] = []
    @Published var lastUpdate: Date?
    
    private let stationsProvider: StationsProviderType
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(stationsProvider: StationsProviderType) {
        self.stationsProvider = stationsProvider
    }
    
    func startFetchingStations() {
        subscribeToUpdates()
    }
    
    private func subscribeToUpdates() {
        self.stationsProvider.publishedStations
        .receive(on: DispatchQueue.main)
        .sink { error in
            
        } receiveValue: { [weak self] stations in
            self?.stations = stations.map { StationViewModel(station: $0) }
        }
        .store(in: &cancellables)
        
        stationsProvider.lastUpdatePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.lastUpdate, on: self)
            .store(in: &cancellables)
    }
    
    func endFetchingStations() {
        stationsProvider.cancelUpdates()
        cancellables.removeAll()
    }
}
