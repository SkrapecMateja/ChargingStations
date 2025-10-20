//
//  ChargingStationsApp.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 17.10.2025.
//

import SwiftUI

@main
struct ChargingStationsApp: App {
    
    let dependencies: AppDependencies = AppDependencies()
    
    var body: some Scene {
        WindowGroup {
            MainTabView(
                viewModel: MainTabViewModel(
                    stationsViewModel: StationsViewModel(stationsProvider: dependencies.stationsProvider, respository: StationsRepository()),
                    mapViewModel: StationsMapViewModel(stationsProvider: dependencies.stationsProvider, locationManager: dependencies.locationManager)
                )
            )
        }
    }
}
