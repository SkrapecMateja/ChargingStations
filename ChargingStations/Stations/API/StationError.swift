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
    case locationUnavailable
    
    var localized: String {
        switch self {
        case .networkUnavailable:
            return "No internet connection"
        case .serviceUnavailable:
            return "Failed to get stations"
        case .unknown:
            return "Oops, something went wrong..."
        case .saveToCacheFailed:
            return "Failed to save data"
        case .readingFromCacheFailed:
            return "Failed to load saved data"
        case .locationUnavailable:
            return "Location unavailable"
        }
    }
}
