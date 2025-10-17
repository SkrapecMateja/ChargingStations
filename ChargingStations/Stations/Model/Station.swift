//
//  Station.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 17.10.2025.
//

struct Station: Codable {
    let id: String
    let latitude: Double
    let longitude: Double
    let availability: Availability
    
    init(apiStation: APIStation) {
        self.id = apiStation.id
        self.latitude = Double(apiStation.geoCoordinates.decimalDegree.latitude) ?? 0
        self.longitude = Double(apiStation.geoCoordinates.decimalDegree.longitude) ?? 0
        self.availability = Availability(rawValue: apiStation.evseStatus) ?? .unknown
    }
}
