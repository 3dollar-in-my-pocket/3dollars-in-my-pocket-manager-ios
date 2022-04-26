import CoreLocation

import RxSwift
import Alamofire

protocol StoreServiceProtocol {
    func fetchMyStore() -> Observable<BossStoreInfoResponse>
    
    func openStore(storeId: String, location: CLLocation) -> Observable<String>
    
    func closeStore(storeId: String) -> Observable<String>
    
    func fetchAroundStores(
        location: CLLocation,
        distance: Int
    ) -> Observable<[BossStoreAroundInfoResponse]>
    
    func updateStore(
        storeId: String,
        introduction: String?
    ) -> Observable<String>
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
            ).responseDecodable(of: ResponseContainer<[BossStoreAroundInfoResponse]>.self) { ressponse in
                if ressponse.isSuccess() {
                    observer.processValue(response: ressponse)
                } else {
                    observer.processHTTPError(response: ressponse)
                }
            }
            return Disposables.create()
        }
    }
    
    func updateStore(
        storeId: String,
        introduction: String?
    ) -> Observable<String> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/boss/store/my-store/\(storeId)"
            let headers = HTTPUtils.defaultHeader()
            let parameters = PatchBossStoreInfoRequest(
                appearanceDays: nil,
                categoriesIds: nil,
                contactsNumber: nil,
                imageUrl: nil,
                introduction: introduction,
                menus: nil,
                name: nil,
                snsUrl: nil
            )
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .patch,
                parameters: parameters,
                encoder: JSONParameterEncoder.default,
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
