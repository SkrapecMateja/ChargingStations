//
//  File.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//
import SwiftUICore

extension Availability {
    var color: Color {
        switch self {
        case .available:
            return .green
        case .outOfService:
            return .red
        case .occupied:
            return .yellow
        case .unknown:
            return .gray
        }
    }
    
    // Would localize in production ready app
    var title: String {
        switch self {
        case .available:
            return "Available"
        case .outOfService:
            return "Out of Service"
        case .occupied:
            return "Occupied"
        case .unknown:
            return "Unknown"
        }
    }
}
