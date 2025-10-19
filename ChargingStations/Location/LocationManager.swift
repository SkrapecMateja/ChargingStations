//
//  LocationManager.swift
//  ChargingStations
//
//  Created by Mateja Skrapec on 18.10.2025.
//

import Combine
import CoreLocation

protocol LocationManagerType {
    func stopUpdatingLocation()
    var locationPublisher: AnyPublisher<CLLocation?, Never> { get }
}

class LocationManager: NSObject, LocationManagerType {
    
    private var locationSubject = CurrentValueSubject<CLLocation?, Never>(nil)
    private let manager = CLLocationManager()
    
    var locationPublisher: AnyPublisher<CLLocation?, Never> {
        locationSubject.eraseToAnyPublisher()
    }
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        requestWhenInUseAuthorization()
        startUpdatingLocation()
    }
    
    private func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    private func startUpdatingLocation() {
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
