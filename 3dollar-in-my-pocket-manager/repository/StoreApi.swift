import CoreLocation

import Alamofire

enum StoreApi {
    case fetchMyStore
    case openStore(storeId: String, location: CLLocation)
    case closeStore(storeId: String)
    case renewStore(storeId: String, location: CLLocation)
    case fetchAroundStores(location: CLLocation, distance: Int)
}

extension StoreApi: ApiRequest {
    var path: String {
        switch self {
        case .fetchMyStore:
            return "/v1/boss/store/me"
        case .openStore(let storeId, let location):
            return "/v1/boss/store/\(storeId)/open?mapLatitude=\(location.coordinate.latitude)&mapLongitude=\(location.coordinate.longitude)"
        case .closeStore(let storeId):
            return "/v1/boss/store/\(storeId)/close"
        case .renewStore(let storeId, _):
            return "/v1/boss/store/\(storeId)/renew"
        case .fetchAroundStores:
            return "/v1/boss/stores/around"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchMyStore:
            return .get
        case .openStore:
            return .post
        case .closeStore:
            return .delete
        case .renewStore:
            return .put
        case .fetchAroundStores:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchMyStore:
            return nil
        case .openStore(_, let location):
            return nil
        case .closeStore(_):
            return nil
        case .renewStore(_, let location):
            return [
                "mapLatitude": location.coordinate.latitude,
                "mapLongitude": location.coordinate.longitude
            ]
        case .fetchAroundStores(let location, let distance):
            return [
                "mapLatitude": location.coordinate.latitude,
                "mapLongitude": location.coordinate.longitude,
                "distanceKm": distance
            ]
        }
    }
}