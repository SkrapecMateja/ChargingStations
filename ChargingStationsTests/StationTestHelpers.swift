//
//  StationTestHelpers.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//
import XCTest
@testable import ChargingStations

struct StationTestHelpers {
    func assertStationsEqual(
        _ lhs: Station,
        _ rhs: Station,
        tolerance: Double = 1e-6,
    ) {
        XCTAssertEqual(lhs.id, rhs.id, "IDs differ")
        XCTAssertEqual(lhs.availability, rhs.availability, "Availability differs")
        XCTAssertTrue(abs(lhs.latitude - rhs.latitude) < tolerance, "Latitude differs")
        XCTAssertTrue(abs(lhs.longitude - rhs.longitude) < tolerance, "Longitude differs")
        XCTAssertEqual(lhs.chargingFacilities, rhs.chargingFacilities, "Facilities differ")
    }
}
