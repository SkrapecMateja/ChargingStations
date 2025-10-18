//
//  ChargingFacilities.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

struct ChargingFacility: Codable, Equatable {
    let power: UInt16
    
    init?(apiFacilities: APIStation.ChargingFacilities) {
        guard let power = apiFacilities.power else { return nil }
        
        self.init(power: power)
    }
    
    init(power: UInt16) {
        self.power = power
    }
}
