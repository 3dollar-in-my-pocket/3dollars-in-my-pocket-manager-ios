import RxSwift
import Alamofire
import Base

extension AnyObserver {
    func processHTTPError<T>(response: AFDataResponse<T>) {
        if let statusCode = response.response?.statusCode {
            if let httpError = HTTPError(rawValue: statusCode) {
                self.onError(httpError)
            } else {
                if let value = response.value {
                    if let responseContainer: ResponseContainer<String> = JsonUtils.decode(object: value) {
                        self.onError(BaseError.custom(responseContainer.message))
                    }
                } else {
                    self.onError(BaseError.unknown)
                }
            }
        } else {
            switch response.result {
            case .failure(let error):
                if error._code == 13 {
                    self.onError(BaseError.timeout)
                }
            default:
                break
            }
        }
    }
    
    func processValue<T>(response: DataResponse<ResponseContainer<T>, AFError>) {
        if let value = response.value {
            self.onNext(value.data as! Element)
            self.onCompleted()
        } else {
            self.onError(BaseError.nilValue)
        }
    }
}
