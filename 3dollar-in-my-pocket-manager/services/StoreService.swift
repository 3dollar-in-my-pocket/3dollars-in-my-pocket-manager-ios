import RxSwift
import Alamofire

protocol StoreServiceProtocol {
    func fetchMyStore() -> Observable<BossStoreInfoResponse>
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
}
