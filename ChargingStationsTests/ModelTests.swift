//
//  ModelTests.swift
//  ChargingStationsTests
//
//  Created by Mateja Skrapec on 17.10.2025.
//

import XCTest
import Foundation
@testable import ChargingStations

class ModelTests: XCTestCase {

    func testStationDecodingAndMappingToModel() async throws {
        let data = try getData(fromJSON: "StationsAPIData")
        let JSONDecoder = JSONDecoder()
        let apiStationsWrapper: APIStationsWrapper = try JSONDecoder.decode(APIStationsWrapper.self, from: data)
        
        let stations = apiStationsWrapper.stations.map { Station(apiStation: $0) }
        
        XCTAssertEqual(stations.count, 50)
        XCTAssertEqual(stations[0].availability, .unknown) // availability not in enum, fallsback to unknown
        XCTAssertEqual(stations[1].availability, .oufOfService)
        XCTAssertEqual(stations[2].availability, .available)
        XCTAssertEqual(stations[3].availability, .occupied)
        XCTAssertEqual(stations[4].availability, .unknown)
        
        // Conversion from String to Double can introduce precision issues but for
        // latitude and longitude that is acceptable
        XCTAssertEqual(stations[0].latitude, 46.957680, accuracy: 0.0000001)
        XCTAssertEqual(stations[0].longitude, 9.548950, accuracy: 0.0000001)
        
        XCTAssertEqual(stations[0].id, "CHFASE4150401")
        
        XCTAssertEqual(stations[1].chargingFacilities.count, 2)
        XCTAssertEqual(stations[1].chargingFacilities[0].power, 50)
        XCTAssertEqual(stations[1].chargingFacilities[1].power, 300)
    }
}

extension XCTestCase {
    enum TestError: Error {
        case fileNotFound
    }
    
    func getData(fromJSON fileName: String) throws -> Data {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: fileName, withExtension: "json")else {
            throw TestError.fileNotFound
        }
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            throw error
        }
    }
}
