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
    }
    
    private func requestWhenInUseAuthorization() {
        DefaultLogger.shared.info("Requestion location authorization.")
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        DefaultLogger.shared.info("Started updating location.")
        guard manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse else {
           return
        }
        stopUpdatingLocation()
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
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                DefaultLogger.shared.info("Authorization granted. Starting updates.")
                // Delay a bit so that location manager is ready and restarted after autorization comes. This is especially important for 'Allow once' because first returned location is nil and we never receive another one in didUpdateLocations
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.startUpdatingLocation()
                }
            case .denied, .restricted:
                DefaultLogger.shared.info("Location access denied or restricted.")
                locationSubject.send(nil)
            case .notDetermined:
                DefaultLogger.shared.info("Authorization not determined yet.")
            @unknown default:
                break
            }
        }
}
