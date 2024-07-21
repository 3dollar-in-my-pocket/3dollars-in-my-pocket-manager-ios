import Foundation
import Alamofire

typealias ApiResult<T: Decodable> = Result<T, Error>

protocol ApiRequest {
    var baseUrl: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
}

extension ApiRequest {
    var baseUrl: String {
        Bundle.apiURL + "/boss"
    }
    
    var dataRequest: DataRequest {
        return AF.request(
            baseUrl + path,
            method: method,
            parameters: parameters,
            encoding: (method == .post) || (method == .patch) ? JSONEncoding.default : URLEncoding.default,
            headers: HTTPUtils.defaultHeader()
        )
    }
    
    func asyncRequest<T: Decodable>() async -> ApiResult<T> {
        let result = await dataRequest.serializingData().result
        
        switch result {
        case .success(let data):
            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(ApiResponse<T>.self, from: data)
                
                if let errorMessage = apiResponse.error {
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
            return .failure(error)
        }
    }
}
