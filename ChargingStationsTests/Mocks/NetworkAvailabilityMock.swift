//
//  NetworkAvailabilityMock.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 20.10.2025.
//

import XCTest
@testable import ChargingStations
import Combine
import CoreLocation

class NetworkAvailabilityMock: ReachabilityMonitoring {
    
    private var networkAvailableSubject = PassthroughSubject<Void, Never>()
    
    var networkAvailablePublisher: AnyPublisher<Void, Never> {
        networkAvailableSubject.eraseToAnyPublisher()
    }
    
    func sendNetworkAvailable() {
        networkAvailableSubject.send(())
    }
}
