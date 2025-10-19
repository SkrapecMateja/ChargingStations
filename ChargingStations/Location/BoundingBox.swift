//
//  BoundingBox.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

import Foundation

struct BoundingBox {
    let minLat: Double
    let maxLat: Double
    let minLon: Double
    let maxLon: Double
    
    var bboxString: String {
        return "\(minLon),\(minLat),\(maxLon),\(maxLat)"
    }
}

