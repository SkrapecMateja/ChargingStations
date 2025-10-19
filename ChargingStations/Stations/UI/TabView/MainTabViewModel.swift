//
//  MainTabViewModel.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

import Combine
import SwiftUICore

class MainTabViewModel: ObservableObject {
    
    let stationsViewModel: StationsViewModel
    let mapViewModel: MapViewModel
    
    private(set) var tabItems: [TabType] = [.map, .list]
    
    @Published var selectedTab: TabType = .map
    
    init(stationsViewModel: StationsViewModel, mapViewModel: MapViewModel) {
        self.stationsViewModel = stationsViewModel
        self.mapViewModel = mapViewModel
    }
    
    func viewAppeared() {
        stationsViewModel.startFetchingStations()
    }
    
    func viewDisappeared() {
        stationsViewModel.endFetchingStations()
    }
}
