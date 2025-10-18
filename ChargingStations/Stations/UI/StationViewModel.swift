//
//  StationViewModel.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

struct StationViewModel: Identifiable {
    let id: String
    let latitude: Double?
    let longitude: Double?
    let availability: Availability
    var lastUpdate: String = ""
    
    init(station: Station) {
        self.id = station.id
        self.latitude = station.latitude
        self.longitude = station.longitude
        self.availability = station.availability
        //self.lastUpdate = station.lastUpdate
    }
}
