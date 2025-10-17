//
//  ChargingFacilities.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

struct ChargingFacility: Codable {
    let power: UInt16
    
    init(apiFacilities: APIStation.ChargingFacilities) {
        self.power = apiFacilities.power
    }
}
