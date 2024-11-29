import Foundation
import CoreLocation
import Combine

extension CLLocationManager {
    func requestLocation() async throws -> CLLocation {
        let delegate = LocationManagerDelegate()
        self.delegate = delegate
        
        if Self.locationServicesEnabled() {
            switch authorizationStatus {
            case .notDetermined:
                requestWhenInUseAuthorization()
            case .restricted, .denied:
                throw LocationError.denied
            case .authorizedAlways, .authorizedWhenInUse, .authorized:
                startUpdatingLocation()
            @unknown default:
                throw LocationError.unknown
            }
        } else {
            delegate.continuation?.resume(throwing: LocationError.disableLocationService)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            delegate.continuation = continuation
        }
    }
}

final class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var continuation: CheckedContinuation<CLLocation, Error>?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        if let location = locations.first {
            continuation?.resume(returning: location)
            continuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        
        var error = error
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                error = LocationError.denied
            case .locationUnknown:
                error = LocationError.unknownLocation
            default:
                break
            }
        }
        
        continuation?.resume(throwing: error)
        continuation = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied, .restricted:
            continuation?.resume(throwing: LocationError.denied)
            continuation = nil
            
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingHeading()
            
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            
        default:
            continuation?.resume(throwing: LocationError.unknown)
            continuation = nil
        }
    }
}
