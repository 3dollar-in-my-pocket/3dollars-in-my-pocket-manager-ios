import Alamofire

enum MapApi {
    case searchAddress(latitude: Double, longitude: Double)
}

extension MapApi: ApiRequest {
    var baseUrl: String {
        switch self {
        case .searchAddress:
            return "https://maps.apigw.ntruss.com"
        }
    }
    
    var path: String {
        switch self {
        case .searchAddress:
            return "/map-reversegeocode/v2/gc"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .searchAddress:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .searchAddress(let latitude, let longitude):
            return [
                "request": "coordsToaddr",
                "coords": "\(longitude),\(latitude)",
                "orders": "legalcode,admcode,addr,roadaddr",
                "output": "json"
            ]
        }
    }
    
    var headers: HTTPHeaders {
        return [
            "x-ncp-apigw-api-key-id": "8px0ex5ba7",
            "x-ncp-apigw-api-key": "ixIeT10RhEF4HC25C7WDXkR6GE28L8rFxpWJRGs8"
        ]
    }
}
