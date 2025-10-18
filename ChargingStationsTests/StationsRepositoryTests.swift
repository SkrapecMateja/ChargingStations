//
//  StationsRepositoryTests.swift
//  ChargingStationsTests
//
//  Created by Mateja Skrapec on 18.10.2025.
//

import XCTest
@testable import ChargingStations

class StationsRepositoryTests: XCTestCase {
    
    let stations: [Station] = [
        Station(id: "CH*12345", latitude: 12.34567, longitude: 9.87352, availability: .available, chargingFacilities: [ChargingFacility(power: 20)], lastUpdate: nil),
        Station(id: "CH*12346", latitude: 12.34555, longitude: 9.87353, availability: .occupied, chargingFacilities: [ChargingFacility(power: 300)], lastUpdate: Date()),
        Station(id: "CH*12347", latitude: 12.3333, longitude: 9.87092, availability: .oufOfService, chargingFacilities: [ChargingFacility(power: 100), ChargingFacility(power: 255)], lastUpdate: Date()),
        Station(id: "CH*12348", latitude: 12.3345, longitude: 9.87887, availability: .unknown, chargingFacilities: [ChargingFacility(power: 200), ChargingFacility(power: 25)], lastUpdate: nil)
    ]

    func testSavingAndLoadingStations() {
        let saveExpectation = expectation(description: "Fetch stations completion called")
        let loadExpectation = expectation(description: "Load stations completion called")

        let stationsRepository = StationsRepository(cacheFileName: "cache.stations.test", lastUpdatedKey: "stations.lastUpdated.test")
        
        stationsRepository.saveStations(stations, completion: { result in
            if case .failure(let error) = result {
                XCTFail("Expected success, but got failure with error: \(error)")
            }
            saveExpectation.fulfill()
        })
        
        stationsRepository.loadStations { result in
            switch result {
            case .success(let loadedStations):
                for i in 0..<self.stations.count {
                    StationTestHelpers().assertStationsEqual(self.stations[i], loadedStations[i])
                }
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
            loadExpectation.fulfill()
        }
        
        wait(for: [saveExpectation, loadExpectation], timeout: 2)
    }
    
    func testSavingAndLoadingLastUpdatedDate() {
        let stationsRepository = StationsRepository(cacheFileName: "cache.stations.test", lastUpdatedKey: "stations.lastUpdated.test")
        
        let now = Date()
        
        stationsRepository.saveLastUpdated(date: now)
        
        let loadedDate = stationsRepository.lastUpdated
        
        XCTAssertEqual(now.timeIntervalSince1970, loadedDate?.timeIntervalSince1970)
    }
}
