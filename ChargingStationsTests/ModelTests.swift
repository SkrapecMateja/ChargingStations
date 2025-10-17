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

    func testStationDecoding() async throws {
        let data = try getData(fromJSON: "StationsData")
        let JSONDecoder = JSONDecoder()
        let stationsWrapper: StationsWrapper = try JSONDecoder.decode(StationsWrapper.self, from: data)
        
        XCTAssertEqual(stationsWrapper.stations.count, 50)
        XCTAssertEqual(stationsWrapper.stations[0].availability, .unknown) // availability not in enum, fallsback to unknown
        XCTAssertEqual(stationsWrapper.stations[1].availability, .oufOfService)
        XCTAssertEqual(stationsWrapper.stations[2].availability, .available)
        XCTAssertEqual(stationsWrapper.stations[3].availability, .occupied)
        XCTAssertEqual(stationsWrapper.stations[4].availability, .unknown)
        
        // Decoding from String to Double can introduce precision issues but for
        // latitude and longitude that is acceptable
        XCTAssertEqual(stationsWrapper.stations[0].latitude, 46.957680, accuracy: 0.0000001)
        XCTAssertEqual(stationsWrapper.stations[0].longitude, 9.548950, accuracy: 0.0000001)
        
        XCTAssertEqual(stationsWrapper.stations[0].id, "CHFASE4150401")
    }
    
    func testStationEncoding() throws {
        let json = """
        {
            "_id": "CHFASE4150401",
            "EvseStatus": "Available",
            "GeoCoordinates": {
                "DecimalDegree": {
                    "Latitude": "46.957680",
                    "Longitude": "9.548950"
                }
            }
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let station = try decoder.decode(Station.self, from: json)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let encodedData = try encoder.encode(station)
        
        // Decode to dictionary for easier checks
        let jsonObject = try JSONSerialization.jsonObject(with: encodedData) as? [String: Any]
        
        XCTAssertEqual(jsonObject?["id"] as? String, "CHFASE4150401")
        XCTAssertEqual(jsonObject?["latitude"] as! Double, 46.957680, accuracy: 0.0000001)
        XCTAssertEqual(jsonObject?["longitude"] as! Double, 9.548950, accuracy: 0.0000001)
        XCTAssertEqual(jsonObject?["availability"] as? String, "Available")
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
