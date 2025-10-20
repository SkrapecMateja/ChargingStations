//
//  StationsRepositoryMock.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 20.10.2025.
//

import XCTest
@testable import ChargingStations
import Combine
import CoreLocation

class StationsRepositoryMock: StationsRepositoryType {
    
    var saveStationsWithError: StationError?
    func saveStations(_ stations: [ChargingStations.Station], completion: @escaping (Result<Void, ChargingStations.StationError>) -> Void) {
        if let error = saveStationsWithError {
            completion(.failure(error))
        } else {
            completion(.success(()))
        }
    }
    
    var loadStationsWithResult: Result<[ChargingStations.Station], ChargingStations.StationError>?
    func loadStations(completion: @escaping (Result<[ChargingStations.Station], ChargingStations.StationError>) -> Void) {
        completion(loadStationsWithResult!)
    }
    
    var calledSaveLastUpdates: Bool = false
    func saveLastUpdated(date: Date) {
        calledSaveLastUpdates = true
    }
    
    var lastUpdatedMock: Date? = Date()
    var lastUpdated: Date? {
        lastUpdatedMock
    }
    
}
