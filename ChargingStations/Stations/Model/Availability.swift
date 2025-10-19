//
//  Availability.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 17.10.2025.
//

enum Availability: String, CaseIterable, Codable, Comparable {
    case available = "Available"
    case outOfService = "OutOfService"
    case occupied = "Occupied"
    case unknown = "Unknown"
    
    var priority: Int {
        switch self {
        case .available: return 4
        case .occupied: return 3
        case .outOfService: return 2
        case .unknown: return 1
        }
    }
    
    static func < (lhs: Availability, rhs: Availability) -> Bool {
        lhs.priority < rhs.priority
    }
}
