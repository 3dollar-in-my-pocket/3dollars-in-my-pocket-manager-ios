import RxSwift
import Alamofire
import Base

extension AnyObserver {
    func processHTTPError<T>(response: AFDataResponse<T>) {
        if let statusCode = response.response?.statusCode {
            if let httpError = HTTPError(rawValue: statusCode) {
                self.onError(httpError)
            } else {
                self.onError(BaseError.unknown)
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
    
    func processValue<T: Decodable>(type: T.Type, response: AFDataResponse<Data>) {
        if let data = response.value {
            if let responseContainer: ResponseContainer<T> = JsonUtils.decode(data: data) {
                self.onNext(responseContainer.data as! Element)
                self.onCompleted()
            } else {
                self.onError(BaseError.nilValue)
            }
        }
    }
    
    func processAPIError(response: AFDataResponse<Data>) {
        if let value = response.value,
           let errorContainer: ResponseContainer<String> = JsonUtils.decode(data: value) {
            self.onError(BaseError.custom(errorContainer.message))
        } else {
            self.processHTTPError(response: response)
        }
    }
}
