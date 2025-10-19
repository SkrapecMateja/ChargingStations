//
//  APIStation.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//
import Foundation

struct APIStationsWrapper: Decodable {
    let stations: [APIStation]

    enum CodingKeys: String, CodingKey {
        case features
    }

    struct Feature: Decodable {
        let properties: APIStation
        let id: String
        let geometry: Geometry
    }
    
    struct Geometry: Decodable {
        let coordinates: [Double]
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let features = try container.decode([Feature].self, forKey: .features)
        
        self.stations = features.map { feature in
            var station = feature.properties
            station.id = feature.id
            station.latitude = feature.geometry.coordinates[1]
            station.longitude = feature.geometry.coordinates[0]
            return station
        }
    }
}

struct APIStation: Decodable {
    var id: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    let evseStatus: String
    let chargingFacilities: [ChargingFacilities]?

    enum CodingKeys: String, CodingKey {
        case evseStatus = "EvseStatus"
        case chargingFacilities = "ChargingFacilities"
    }

    struct ChargingFacilities: Decodable {
        let power: UInt16?
        
        enum CodingKeys: String, CodingKey {
            case power = "Power"
        }
    }
}
