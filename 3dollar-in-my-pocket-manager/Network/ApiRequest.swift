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
        let result = await dataRequest.serializingData().result
        
        switch result {
        case .success(let data):
            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(ApiResponse<T>.self, from: data)
                
                if let errorMessage = apiResponse.message {
                    return .failure(ApiError.serverError(errorMessage))
                }
                
                guard let decodableData = apiResponse.data else {
                    return .failure(ApiError.emptyData)
                }
                
                return .success(decodableData)
            } catch {
                return .failure(error)
            }
        case .failure(let error):
            print("[Error] [\(#function)]: \(error)")
            return .failure(error)
        }
    }
}
