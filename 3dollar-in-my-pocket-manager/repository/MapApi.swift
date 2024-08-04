import Alamofire

enum MapApi {
    case searchAddress(latitude: Double, longitude: Double)
}

extension MapApi: ApiRequest {
    var baseUrl: String {
        switch self {
        case .searchAddress:
            return "https://naveropenapi.apigw.ntruss.com"
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
            "X-NCP-APIGW-API-KEY-ID": "hqqqtcv85g",
            "X-NCP-APIGW-API-KEY": "Nk7L8VvCq9YkDuGPjvGDN8FW5ELfWTt23AgcS9ie"
        ]
    }
}
