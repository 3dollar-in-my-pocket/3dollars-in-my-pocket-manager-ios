import RxSwift
import Alamofire

protocol MapServiceProtocol {
    func searchAddress(latitude: Double, longitude: Double) -> Observable<String>
}

struct MapService: MapServiceProtocol {
    func searchAddress(latitude: Double, longitude: Double) -> Observable<String> {
        return .create { observer in
            let urlString = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc"
            let headers: HTTPHeaders = [
                "X-NCP-APIGW-API-KEY-ID": "hqqqtcv85g",
                "X-NCP-APIGW-API-KEY": "Nk7L8VvCq9YkDuGPjvGDN8FW5ELfWTt23AgcS9ie"
            ] as HTTPHeaders
            let parameters: [String: Any] = [
                "request": "coordsToaddr",
                "coords": "\(longitude),\(latitude)",
                "orders": "legalcode,admcode,addr,roadaddr",
                "output": "json"
            ]
            
            AF.request(
                urlString,
                method: .get,
                parameters: parameters,
                headers: headers
            ).responseDecodable(of: NaverMapResponse.self) { response in
                if response.isSuccess() {
                    if let address = response.value {
                        observer.onNext(address.getAddress())
                    } else {
                        observer.onError(BaseError.nilValue)
                    }
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            
            return Disposables.create()
        }
    }
}
