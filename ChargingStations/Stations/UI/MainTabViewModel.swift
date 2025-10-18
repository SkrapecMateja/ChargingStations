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
    
    private(set) var tabItems: [TabItem] = []
    
    @Published var selectedTab: TabType = .map
    
    init(stationsViewModel: StationsViewModel) {
        self.stationsViewModel = stationsViewModel
        
        tabItems = [
            TabItem(tab: .map, title: "Map", icon: "map", view: AnyView(StationsMapView(viewModel: self.stationsViewModel))),
            TabItem(tab: .list, title: "List", icon: "list.bullet", view: AnyView(StationsListView(viewModel: self.stationsViewModel)))
            ]
    }
    
    func viewAppeared() {
        stationsViewModel.startFetchingStations()
    }
    
    func viewDisappeared() {
        stationsViewModel.endFetchingStations()
    }
}
