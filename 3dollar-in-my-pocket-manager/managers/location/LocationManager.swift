import RxSwift
import CoreLocation

protocol LocationManagerProtocol {
    /// 현재 위치를 조회합니다.
    func getCurrentLocation() -> Observable<CLLocation>
}

final class LocationManager: NSObject, LocationManagerProtocol {
    static let shared = LocationManager()
    private var manager = CLLocationManager()
    fileprivate var locationPublisher = PublishSubject<CLLocation>()
    
    override init() {
        super.init()
        
        self.manager.delegate = self
    }
    
    func getCurrentLocation() -> Observable<CLLocation> {
        if CLLocationManager.locationServicesEnabled() {
            if self.manager.authorizationStatus == .notDetermined {
                self.manager.requestWhenInUseAuthorization()
            } else {
                self.locationPublisher = PublishSubject<CLLocation>()
                self.manager.startUpdatingLocation()
            }
            
            return self.locationPublisher
        } else {
            return .error(LocationError.disableLocationService)
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        switch status {
        case .denied, .restricted:
            self.locationPublisher.onError(LocationError.denied)
            
        case .authorizedAlways, .authorizedWhenInUse:
            self.manager.startUpdatingLocation()
            
        case .notDetermined:
            self.manager.requestWhenInUseAuthorization()
            
        default:
            self.locationPublisher.onError(LocationError.unknown)
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        self.manager.stopUpdatingLocation()
        
        guard let lastLocation = locations.last else { return }
        
        self.locationPublisher.onNext(lastLocation)
        self.locationPublisher.onCompleted()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError {
            switch error.code {
            case .denied:
                self.locationPublisher.onError(LocationError.denied)
                
            case .locationUnknown:
                self.locationPublisher.onError(LocationError.unknownLocation)
                
            default:
                self.locationPublisher.onError(LocationError.unknown)
            }
        } else {
            self.locationPublisher.onError(LocationError.unknown)
        }
    }
}
