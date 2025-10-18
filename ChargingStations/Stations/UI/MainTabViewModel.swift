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
    
    private(set) var tabItems: [TabType] = [.map, .list]
    
    @Published var selectedTab: TabType = .map
    
    init(stationsViewModel: StationsViewModel) {
        self.stationsViewModel = stationsViewModel
    }
    
    func viewAppeared() {
        stationsViewModel.startFetchingStations()
    }
    
    func viewDisappeared() {
        stationsViewModel.endFetchingStations()
    }
}
