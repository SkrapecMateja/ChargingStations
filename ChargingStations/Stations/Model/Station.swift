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
        self.id = apiStation.id
        self.latitude = Double(apiStation.geoCoordinates.decimalDegree.latitude) ?? 0
        self.longitude = Double(apiStation.geoCoordinates.decimalDegree.longitude) ?? 0
        self.availability = Availability(rawValue: apiStation.evseStatus) ?? .unknown
        if let updateDate = apiStation.lastUpdate {
            self.lastUpdate = Station.isoFormatter.date(from: updateDate)
        }
        self.chargingFacilities = apiStation.chargingFacilities.map { ChargingFacility(apiFacilities: $0) }
    }
}
