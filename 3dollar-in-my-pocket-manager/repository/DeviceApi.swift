import Alamofire

enum DeviceApi {
    case register(fcmToken: String)
}

extension DeviceApi: ApiRequest {
    var path: String {
        switch self {
        case .register:
            return "/v2/device"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .register:
            return .put
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .register(let token):
            return [
                "pushToken": token,
                "pushPlatformType": "FCM"
            ]
        }
    }
}
