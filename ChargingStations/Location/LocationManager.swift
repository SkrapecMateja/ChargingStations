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
        DefaultLogger.shared.info("Requestion location authorization.")
        manager.requestWhenInUseAuthorization()
    }
    
    private func startUpdatingLocation() {
        DefaultLogger.shared.info("Started updating location.")
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        DefaultLogger.shared.info("Ended updating location.")
        manager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        DefaultLogger.shared.info("Location updated: \(lastLocation)")
        locationSubject.send(lastLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DefaultLogger.shared.error("Location failed: \(error.localizedDescription)")
        locationSubject.send(nil)
    }
}
