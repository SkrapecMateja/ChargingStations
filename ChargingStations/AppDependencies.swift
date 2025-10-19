//
//  AppDependencies.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 19.10.2025.
//

struct AppDependencies {
    let locationManager: LocationManagerType
    let stationsProvider: StationsProviderType

    init() {
        let locationManager = LocationManager()
        self.locationManager = locationManager
        
        self.stationsProvider = StationsProvider(
            repository: StationsRepository(),
            locationManager: locationManager,
            client: StationClient(),
            boundingBoxCalculator: BoundingBoxCalculator()
        )
    }
}
