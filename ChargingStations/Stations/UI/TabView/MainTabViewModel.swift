//
//  MainTabViewModel.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

import Combine
import SwiftUICore

final class MainTabViewModel: ObservableObject {
    
    let stationsViewModel: StationsViewModel
    let mapViewModel: StationsMapViewModel
    
    private(set) var tabItems: [TabType] = [.map, .list]
    
    @Published var selectedTab: TabType = .map
    
    init(stationsViewModel: StationsViewModel, mapViewModel: StationsMapViewModel) {
        self.stationsViewModel = stationsViewModel
        self.mapViewModel = mapViewModel
    }
    
    func viewAppeared() {
        DefaultLogger.shared.info("Main Tab View appeared.")
        stationsViewModel.startFetchingStations()
    }
    
    func viewDisappeared() {
        DefaultLogger.shared.info("Main Tab View disappeared.")
        stationsViewModel.endFetchingStations()
    }
}
