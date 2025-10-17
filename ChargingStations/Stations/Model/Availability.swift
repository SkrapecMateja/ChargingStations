//
//  Availability.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 17.10.2025.
//

enum Availability: String, CaseIterable, Codable {
    case available = "Available"
    case oufOfService = "OutOfService"
    case occupied = "Occupied"
    case unknown = "Unknown"
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        switch stringValue {
        case "Available":
            self = .available
        case "OutOfService":
            self = .oufOfService
        case "Occupied":
            self = .occupied
        default:
            self = .unknown
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .available:
            try container.encode("Available")
        case .oufOfService:
            try container.encode("OutOfService")
        case .occupied:
            try container.encode("Occupied")
        case .unknown:
            try container.encode("Unknown")
        }
    }
}
