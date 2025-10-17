//
//  APIStation.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

struct APIStationsWrapper: Decodable {
    let stations: [APIStation]

    enum CodingKeys: String, CodingKey {
        case features
    }

    struct Feature: Decodable {
        let properties: APIStation
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let features = try container.decode([Feature].self, forKey: .features)
        self.stations = features.map { $0.properties }
    }
}

struct APIStation: Decodable {
    let id: String
    let evseStatus: String
    let geoCoordinates: GeoCoordinates
    let chargingFacilities: [ChargingFacilities]

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case evseStatus = "EvseStatus"
        case geoCoordinates = "GeoCoordinates"
        case chargingFacilities = "ChargingFacilities"
    }

    struct GeoCoordinates: Decodable {
        let decimalDegree: DecimalDegree
        
        enum CodingKeys: String, CodingKey {
            case decimalDegree = "DecimalDegree"
        }
    }

    struct DecimalDegree: Decodable {
        let latitude: String
        let longitude: String
        
        enum CodingKeys: String, CodingKey {
            case latitude = "Latitude"
            case longitude = "Longitude"
        }
    }
    
    struct ChargingFacilities: Decodable {
        let power: UInt16
        
        enum CodingKeys: String, CodingKey {
            case power = "Power"
        }
    }
}
