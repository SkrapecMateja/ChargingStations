//
//  Station.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 17.10.2025.
//
import Foundation

struct Station: Codable {
    let id: String
    let latitude: Double
    let longitude: Double
    let availability: Availability
    let chargingFacilities: [ChargingFacility]
    
    init(apiStation: APIStation) {
        
        let chargingFacilities = apiStation.chargingFacilities?.compactMap { ChargingFacility(apiFacilities: $0) } ?? []
        
        self.init(id: apiStation.id,
                  latitude: apiStation.latitude,
                  longitude: apiStation.longitude,
                  availability: Availability(rawValue: apiStation.evseStatus) ?? .unknown,
                  chargingFacilities: chargingFacilities)
    }
    
    init(id: String,
         latitude: Double,
         longitude: Double,
         availability: Availability,
         chargingFacilities: [ChargingFacility]) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.availability = availability
        self.chargingFacilities = chargingFacilities
    }
    
    var maxPower: UInt16 {
        chargingFacilities.map({ $0.power }).max() ?? 0
    }
}
