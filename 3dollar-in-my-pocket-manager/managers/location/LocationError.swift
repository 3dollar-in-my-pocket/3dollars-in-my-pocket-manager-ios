import Foundation

enum LocationError: LocalizedError {
    case denied
    case unknown
    case unknownLocation
    case disableLocationService
    
    var localizedDescription: String {
        switch self {
        case .denied:
            return "location_deny_description".localized
            
        case .unknown:
            return "error_unknown".localized
            
        case .unknownLocation:
            return "location_unknown".localized
            
        case .disableLocationService:
            return "location_disable_service".localized
        }
    }
}
