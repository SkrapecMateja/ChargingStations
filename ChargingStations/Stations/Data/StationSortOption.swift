//
//  SortOption.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//
import Foundation

enum StationSortOption {
    case power
    
    func apply(to stations: [Station]) -> [Station] {
        switch self {
        case .power:
            stations.sorted(by: { $0.maxPower ?? 0 > $1.maxPower ?? 0 })
        }
    }
}
