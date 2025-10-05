import RxSwift
import Alamofire
import FirebaseMessaging

protocol DeviceServiceType {
    func registerDevice() -> Observable<Void>
    
    func unregisterDevice() -> Observable<Void>
}

struct DeviceService: DeviceServiceType {
    func registerDevice() -> Observable<Void> {
        return .create { observer in
            #if targetEnvironment(simulator)
            // 시뮬레이터에서는 푸시 알림을 지원하지 않으므로 바로 성공 처리
            observer.onNext(())
            observer.onCompleted()
            #else
            // 실제 디바이스에서는 FCM 토큰 사용
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
            #endif
            
            return Disposables.create()
        }
    }
    
    func unregisterDevice() -> Observable<Void> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/boss/v1/device"
            let headers = HTTPUtils.defaultHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .delete,
                headers: headers
            )
            .responseData { response in
                if response.isSuccess() {
                    observer.onNext(())
                    observer.onCompleted()
                } else {
                    observer.processAPIError(response: response)
                }
            }
            
            return Disposables.create()
        }
    }
}
