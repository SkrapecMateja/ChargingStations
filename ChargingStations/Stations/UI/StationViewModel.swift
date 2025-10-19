//
//  StationViewModel.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//
import Foundation

struct StationViewModel: Identifiable {
    let id: String
    let latitude: Double
    let longitude: Double
    let availability: Availability
    let maxPowerText: String
    var chargingFacilities: [ChargingFacilityViewModel] = []
    let chargingStationId: String
    
    init(station: Station) {
        self.id = station.id
        self.latitude = station.latitude
        self.longitude = station.longitude
        self.availability = station.availability
        self.chargingStationId = station.chargingStationId

        if let maxPower = station.maxPower {
            self.maxPowerText = "Max power: \(maxPower) kW"
        } else {
            self.maxPowerText = ""
        }
        
        self.chargingFacilities = station.chargingFacilities.map { ChargingFacilityViewModel(facility: $0) }
    }
}

struct ChargingFacilityViewModel: Identifiable {
    let power: UInt16
    var id: UUID = UUID()
    var powerText: String = ""
    
    init(facility: ChargingFacility) {
        self.power = facility.power
        self.powerText = "\(facility.power) kW"
    }
}
