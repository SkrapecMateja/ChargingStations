//
//  StationClientMock.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 20.10.2025.
//

import XCTest
@testable import ChargingStations
import Combine
import CoreLocation

class StationClientMock: StationFetching {
    
    var stationsFetchingResult: Result<[APIStation], StationError> = .success([])
    
    func fetchStations(boundingBox: ChargingStations.BoundingBox) -> AnyPublisher<[ChargingStations.APIStation], ChargingStations.StationError> {
            switch stationsFetchingResult {
            case .success(let stations):
                return Just(stations)
                    .setFailureType(to: ChargingStations.StationError.self)
                    .eraseToAnyPublisher()
                
            case .failure(let error):
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
        }
}
