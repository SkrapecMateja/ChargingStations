//
//  StationsProviderTests.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//
import XCTest
@testable import ChargingStations
import Combine
import CoreLocation

class StationsProviderTests: XCTestCase {
    
    private var repositiory = StationsRepositoryMock()
    private var locationMananager = LocationManagerMock()
    private var client = StationClientMock()
    private var networkAvailability = NetworkAvailabilityMock()
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var mockLocation: CLLocation {
        .init(latitude: 47.410802, longitude: 8.5427098)
    }
    
    override func setUpWithError() throws {
        repositiory = StationsRepositoryMock()
        locationMananager = LocationManagerMock()
        client = StationClientMock()
        networkAvailability = NetworkAvailabilityMock()
        cancellables.removeAll()
    }

    func testThatStationsWillBeFetchedWhenLocationReceived() {
        let stationsProvider = StationsProvider(repository: repositiory, locationManager: locationMananager, client: client, networkAvailability: networkAvailability, updateInterval: 0.5)
        
        let locationReloadExpectation = expectation(description: "Stations fetched on location update")
        
        // New location sent
        locationMananager.send(location: mockLocation)
        
        stationsProvider.publishedStations.sink { result in
            switch result {
            case .success:
                locationReloadExpectation.fulfill()
            case .failure(let error):
                XCTFail("Expected stations, received \(error).")
            }
        }.store(in: &cancellables)
        
        wait(for: [locationReloadExpectation], timeout: 1)
    }
    
    func testThatStationsWillBeFetchedWhenNetworkIsAvailable() {
        let stationsProvider = StationsProvider(repository: repositiory, locationManager: locationMananager, client: client, networkAvailability: networkAvailability, updateInterval: 0.5)
        
        let networkExpectation = expectation(description: "Stations fetched on network available")
    
        networkAvailability.sendNetworkAvailable()
        
        stationsProvider.publishedStations.sink { result in
            switch result {
            case .success:
                networkExpectation.fulfill()
            case .failure(let error):
                XCTFail("Expected stations, received \(error).")
            }
        }.store(in: &cancellables)
        
        wait(for: [networkExpectation], timeout: 1)
    }
}
