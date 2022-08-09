import RxSwift
import Alamofire
import FirebaseMessaging

protocol DeviceServiceType {
    func registerDevice() -> Observable<Void>
}

struct DeviceService: DeviceServiceType {
    func registerDevice() -> Observable<Void> {
        return .create { observer in
            Messaging.messaging().token { token, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    guard let token = token else {
                        return observer.onError(BaseError.custom("token이 없습니다."))
                    }
                    let urlString = HTTPUtils.url + "/boss/v1/device"
                    let headers = HTTPUtils.jsonWithTokenHeader()
                    let body = UpsertBossDeviceRequest(pushToken: token)
                    
                    HTTPUtils.defaultSession.request(
                        urlString,
                        method: .put,
                        parameters: body,
                        encoder: JSONParameterEncoder.default,
                        headers: headers
                    ).responseData { response in
                        if response.isSuccess() {
                            observer.onNext(())
                            observer.onCompleted()
                        } else {
                            observer.processAPIError(response: response)
                        }
                    }
                }
            }
            
            return Disposables.create()
        }
    }
}
