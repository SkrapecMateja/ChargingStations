//
//  LocationManagerMock.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 20.10.2025.
//
import XCTest
@testable import ChargingStations
import Combine
import CoreLocation

class LocationManagerMock: LocationManagerType {
    
    var calledStopUpdates: Bool = false
    func stopUpdatingLocation() {
        self.calledStopUpdates = true
    }

    private let subject = CurrentValueSubject<CLLocation?, Never>(CLLocation(latitude: 47.410886, longitude: 8.5427086))
       
    var locationPublisher: AnyPublisher<CLLocation?, Never> {
        subject.eraseToAnyPublisher()
    }
       
    var currentLocation: CLLocation? {
        subject.value
    }
    
    // Helper method to trigger location updates in tests
    func send(location: CLLocation?) {
        subject.send(location)
    }
}
