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
    
    var metersDiffLongitude: Double {
        (maxLon - minLon) * 111.0 * cos((minLat + maxLat)/2 * .pi/180) * 1000
    }
    
    var metersDiffLatitude: Double {
        (maxLat - minLat) * 111.0 * 1000
    }
}

