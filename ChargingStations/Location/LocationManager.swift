//
//  LocationManager.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

import Combine
import CoreLocation

protocol LocationManagerType {
    func requestWhenInUseAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
    var locationPublisher: AnyPublisher<CLLocation?, Never> { get }
    var currentLocation: CLLocation? { get }
    var defaultCoordinate: CLLocationCoordinate2D { get }
}

class LocationManager: NSObject, LocationManagerType {
    
    private var locationSubject = CurrentValueSubject<CLLocation?, Never>(nil)
    private let manager = CLLocationManager()
    
    let defaultCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 47.3769, longitude: 8.5417) // Zurich
    
    var locationPublisher: AnyPublisher<CLLocation?, Never> {
        locationSubject.eraseToAnyPublisher()
    }
    
    var currentLocation: CLLocation? {
        locationSubject.value
    }
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        requestWhenInUseAuthorization()
        startUpdatingLocation()
    }
    
    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationSubject.send(locations.last)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationSubject.send(nil)
    }
}
