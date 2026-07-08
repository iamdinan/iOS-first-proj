//
//  LocationService.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import CoreLocation

@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    var lastLocation: CLLocation? = nil
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        manager.startUpdatingLocation()
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
    }

    // MARK: - Delegate
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
}
