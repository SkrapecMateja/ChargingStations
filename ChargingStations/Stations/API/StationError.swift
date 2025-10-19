//
//  StationError.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 17.10.2025.
//

enum StationError: Error, Equatable {
    case networkUnavailable       // no internet connection
    case serviceUnavailable       // API failed
    case unknown                  // fallback
    case saveToCacheFailed
    case readingFromCacheFailed
}
