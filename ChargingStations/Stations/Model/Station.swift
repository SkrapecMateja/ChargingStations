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
    var lastUpdate: Date? = nil
    
    static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()
    
    init(apiStation: APIStation) {
        
        let chargingFacilities = apiStation.chargingFacilities.map { ChargingFacility(apiFacilities: $0) }
        
        var lastUpdate: Date? = nil
        if let updateDate = apiStation.lastUpdate {
            lastUpdate = Station.isoFormatter.date(from: updateDate)
        }
        
        self.init(id: apiStation.id,
                  latitude: Double(apiStation.geoCoordinates.decimalDegree.latitude) ?? 0,
                  longitude: Double(apiStation.geoCoordinates.decimalDegree.longitude) ?? 0,
                  availability: Availability(rawValue: apiStation.evseStatus) ?? .unknown,
                  chargingFacilities: apiStation.chargingFacilities.map { ChargingFacility(apiFacilities: $0) },
                  lastUpdate: lastUpdate)
    }
    
    init(id: String,
         latitude: Double,
         longitude: Double,
         availability: Availability,
         chargingFacilities: [ChargingFacility],
         lastUpdate: Date?) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.availability = availability
        self.chargingFacilities = chargingFacilities
        self.lastUpdate = lastUpdate
    }
}
