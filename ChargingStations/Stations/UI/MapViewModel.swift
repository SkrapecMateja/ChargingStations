//
//  MapViewModel.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

import Foundation
import Combine
import MapKit
import _MapKit_SwiftUI

class MapViewModel: ObservableObject {
    @Published var currentLocation: CLLocationCoordinate2D = .init() {
        didSet {
            mapCameraBounds = MapCameraBounds(
                centerCoordinateBounds: MKMapRect(
                    origin: MKMapPoint(currentLocation),
                    size: MKMapSize(width: radiusMeters, height: radiusMeters)
                ),
                minimumDistance: radiusMeters,
                maximumDistance: radiusMeters
            )
        }
    }
    @Published var mapCameraBounds: MapCameraBounds?
    
    private let radiusMeters: CLLocationDistance = 10000
}
