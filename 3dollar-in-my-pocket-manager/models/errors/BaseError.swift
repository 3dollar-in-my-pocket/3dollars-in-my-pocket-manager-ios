import Foundation

enum BaseError: LocalizedError {
    case custom(String)
    case unknown
    case timeout
    case failDecoding
    case nilValue
    
    var errorDescription: String? {
        switch self {
        case .custom(let message):
            return message
            
        case .unknown:
            return "error_unknown".localized
            
        case .timeout:
            return "error_time_out".localized
            
        case .failDecoding:
            return "error_fail_decode".localized
            
        case .nilValue:
            return "error_nil_value".localized
        }
    }
}
