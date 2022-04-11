import CoreLocation

import RxSwift
import Alamofire

protocol StoreServiceProtocol {
    func fetchMyStore() -> Observable<BossStoreInfoResponse>
    
    func openStore(storeId: String, location: CLLocation) -> Observable<String>
    
    func closeStore(storeId: String) -> Observable<String>
}

struct StoreService: StoreServiceProtocol {
    func fetchMyStore() -> Observable<BossStoreInfoResponse> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/boss/store/my-store"
            let headers = HTTPUtils.defaultHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                headers: headers
            ).responseDecodable(of: ResponseContainer<BossStoreInfoResponse>.self) { response in
                if response.isSuccess() {
                    observer.processValue(response: response)
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func openStore(storeId: String, location: CLLocation) -> Observable<String> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/boss/store/\(storeId)/open"
            let headers = HTTPUtils.defaultHeader()
            let parameters: [String: Any] = [
                "mapLatitude": location.coordinate.latitude,
                "mapLongitude": location.coordinate.longitude
            ]
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .put,
                parameters: parameters,
                headers: headers
            ).responseDecodable(of: ResponseContainer<String>.self) { response in
                if response.isSuccess() {
                    observer.processValue(response: response)
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func closeStore(storeId: String) -> Observable<String> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/boss/store/\(storeId)/close"
            let headers = HTTPUtils.defaultHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .put,
                headers: headers
            ).responseDecodable(of: ResponseContainer<String>.self) { response in
                if response.isSuccess() {
                    observer.processValue(response: response)
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            
            return Disposables.create()
        }
    }
}
