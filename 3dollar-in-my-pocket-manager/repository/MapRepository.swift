import Foundation

import Alamofire

protocol MapRepository {
    func searchAddress(latitude: Double, longitude: Double) async -> ApiResult<String>
}

final class MapRepositoryImpl: MapRepository {
    func searchAddress(latitude: Double, longitude: Double) async -> ApiResult<String> {
        let dataRequest = MapApi.searchAddress(latitude: latitude, longitude: longitude).dataRequest
        let result = await dataRequest.serializingData().result
        
        switch result {
        case .success(let data):
            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(NaverMapResponse.self, from: data)
                
                return .success(apiResponse.getAddress())
            } catch {
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}
