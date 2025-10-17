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
}
