//
//  ChargingFacilities.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

struct ChargingFacility: Codable, Equatable {
    let power: UInt16
    
    init(apiFacilities: APIStation.ChargingFacilities) {
        self.init(power: apiFacilities.power)
    }
    
    init(power: UInt16) {
        self.power = power
    }
}
