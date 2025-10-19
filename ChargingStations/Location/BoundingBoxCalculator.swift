//
//  BoundingBoxCalculator.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

import CoreLocation
import Foundation

struct BoundingBoxCalculator {
    func boundingBox(center: CLLocationCoordinate2D, radiusKm: Double) -> BoundingBox {
        let positiveCoordinates = self.positiveCoordinates(from: center)
        let lat = positiveCoordinates.latitude
        let lon = positiveCoordinates.longitude
        
        // Latitude delta (~111 km per degree)
        let latDelta = radiusKm / 111.0
        
        // Longitude delta (depends on latitude)
        let lonDelta = radiusKm / (111.0 * cos(lat * .pi / 180))
        
        let minLat = lat - latDelta
        let maxLat = lat + latDelta
        let minLon = lon - lonDelta
        let maxLon = lon + lonDelta
        
        return BoundingBox(minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon)
    }
    
    func positiveCoordinates(from coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let lat = coordinate.latitude >= 0 ? coordinate.latitude : -coordinate.latitude
        let lon = coordinate.longitude >= 0 ? coordinate.longitude : coordinate.longitude + 360
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
