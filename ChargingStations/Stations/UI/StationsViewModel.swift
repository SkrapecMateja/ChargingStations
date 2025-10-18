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
    
    private let stationsProvider: StationsProviderType
    private var cancellables: Set<AnyCancellable> = []
    
    init(stationsProvider: StationsProviderType) {
        self.stationsProvider = stationsProvider
    }
    
    func startFetchingStations() {
        subscribeToUpdates()
        stationsProvider.startUpdates(for: BoundingBox(x1: 1, y1: 2, x2: 3, y2: 4))
    }
    
    private func subscribeToUpdates() {
        self.stationsProvider.publishedStations
        .receive(on: DispatchQueue.main)
        .sink { error in
            
        } receiveValue: { [weak self] stations in
            self?.stations = stations.map { StationViewModel(station: $0) }
        }
        .store(in: &cancellables)
    }
    
    func endFetchingStations() {
        stationsProvider.cancelUpdates()
        cancellables.removeAll()
    }
}
