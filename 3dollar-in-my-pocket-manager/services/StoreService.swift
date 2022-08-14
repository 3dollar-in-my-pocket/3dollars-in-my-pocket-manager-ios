import CoreLocation

import RxSwift
import Alamofire

protocol StoreServiceType {
    func fetchMyStore() -> Observable<BossStoreInfoResponse>
    
    func openStore(storeId: String, location: CLLocation) -> Observable<String>
    
    func closeStore(storeId: String) -> Observable<String>
    
    func renewStore(storeId: String, location: CLLocation) -> Observable<String>
    
    func fetchAroundStores(
        location: CLLocation,
        distance: Int
    ) -> Observable<[BossStoreAroundInfoResponse]>
    
    func updateStore(store: Store) -> Observable<String>
}

struct StoreService: StoreServiceType {
    func fetchMyStore() -> Observable<BossStoreInfoResponse> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/boss/store/me"
            let headers = HTTPUtils.defaultHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                headers: headers
            )
            .responseData(completionHandler: { response in
                if response.isSuccess() {
                    observer.processValue(type: BossStoreInfoResponse.self, response: response)
                } else {
                    observer.processAPIError(response: response)
                }
            })
            
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
                method: .post,
                parameters: parameters,
                headers: headers
            )
            .responseData(completionHandler: { response in
                if response.isSuccess() {
                    observer.processValue(type: String.self, response: response)
                } else {
                    observer.processAPIError(response: response)
                }
            })
            
            return Disposables.create()
        }
    }
    
    func closeStore(storeId: String) -> Observable<String> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/boss/store/\(storeId)/close"
            let headers = HTTPUtils.defaultHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .delete,
                headers: headers
            )
            .responseData(completionHandler: { response in
                if response.isSuccess() {
                    observer.processValue(type: String.self, response: response)
                } else {
                    observer.processAPIError(response: response)
                }
            })
            
            return Disposables.create()
        }
    }
    
    func renewStore(storeId: String, location: CLLocation) -> Observable<String> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/boss/store/\(storeId)/renew"
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
            ).responseData(completionHandler: { response in
                if response.isSuccess() {
                    observer.processValue(type: String.self, response: response)
                } else {
                    observer.processAPIError(response: response)
                }
                
            })
            
            return Disposables.create()
        }
    }
    
    func fetchAroundStores(
        location: CLLocation,
        distance: Int
    ) -> Observable<[BossStoreAroundInfoResponse]> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/boss/stores/around"
            let headers = HTTPUtils.jsonHeader()
            let parameters: [String: Any] = [
                "mapLatitude": location.coordinate.latitude,
                "mapLongitude": location.coordinate.longitude,
                "distanceKm": distance
            ]
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                parameters: parameters,
                headers: headers
            )
            .responseData(completionHandler: { response in
                if response.isSuccess() {
                    observer.processValue(
                        type: [BossStoreAroundInfoResponse].self,
                        response: response
                    )
                } else {
                    observer.processAPIError(response: response)
                }
            })
            
            return Disposables.create()
        }
    }
    
    func updateStore(store: Store) -> Observable<String> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/boss/store/\(store.id)"
            let headers = HTTPUtils.defaultHeader()
            let parameters = PatchBossStoreInfoRequest(store: store)
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .patch,
                parameters: parameters,
                encoder: JSONParameterEncoder.default,
                headers: headers
            ).responseData(completionHandler: { response in
                if response.isSuccess() {
                    observer.processValue(type: String.self, response: response)
                } else {
                    observer.processAPIError(response: response)
                }
            })
            
            return Disposables.create()
        }
    }
}
