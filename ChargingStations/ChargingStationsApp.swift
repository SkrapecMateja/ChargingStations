//
//  ChargingStationsApp.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 17.10.2025.
//

import SwiftUI

@main
struct ChargingStationsApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView(viewModel: MainTabViewModel(
                stationsViewModel: StationsViewModel(
                    stationsProvider: StationsProvider(
                        repository: StationsRepository(),
                        client: StationClient())
                    )
                )
            )
        }
    }
}
