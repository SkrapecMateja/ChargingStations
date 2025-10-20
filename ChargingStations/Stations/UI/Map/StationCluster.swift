//
//  StationCluster.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 20.10.2025.
//

struct StationCluster: Identifiable {
    let clusterId: String
    let latitude: Double
    let longitude: Double
    
    var bestAvailability: Availability {
        stations.map(\.availability).max() ?? .unknown
    }
    
    var id: String { clusterId }
    
    let stations: [StationViewModel]
}
