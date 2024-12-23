import Foundation
import Alamofire

typealias ApiResult<T: Decodable> = Result<T, Error>

protocol ApiRequest {
    var baseUrl: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var headers: HTTPHeaders { get }
}

extension ApiRequest {
    var baseUrl: String {
        Bundle.apiURL + "/boss"
    }
    
    var headers: HTTPHeaders {
        return HTTPUtils.defaultHeader()
    }
    
    var dataRequest: DataRequest {
        return AF.request(
            baseUrl + path,
            method: method,
            parameters: parameters,
            encoding: (method == .post) || (method == .patch) ? JSONEncoding.default : URLEncoding.default,
            headers: headers
        )
    }
    
    func asyncRequest<T: Decodable>() async -> ApiResult<T> {
        let response = await dataRequest.serializingData().response
        
        if response.isSuccess().isNot {
            guard let data = response.data else { return .failure(ApiError.emptyData) }
            
            do {
                let decoder = JSONDecoder()
                let errorContainer = try decoder.decode(ApiErrorContainer.self, from: data)
                
                return .failure(ApiError.errorContainer(errorContainer))
            } catch {
                return .failure(ApiError.decodingError)
            }
        } else {
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let apiResponse = try decoder.decode(ApiResponse<T>.self, from: data)
                    
                    guard let decodableData = apiResponse.data else {
                        return .failure(ApiError.emptyData)
                    }
                    
                    return .success(decodableData)
                } catch {
                    return .failure(error)
                }
            case .failure(let error):
                return .failure(error)
            }
        }
    }
}
