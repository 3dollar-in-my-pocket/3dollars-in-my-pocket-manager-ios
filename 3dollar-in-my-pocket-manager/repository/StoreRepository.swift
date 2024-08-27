import CoreLocation

import Alamofire

protocol StoreRepository {
    func fetchMyStore() async -> ApiResult<BossStoreResponse>
    
    func openStore(storeId: String, location: CLLocation) async -> ApiResult<String>
    
    func closeStore(storeId: String) async -> ApiResult<String>
    
    func renewStore(storeId: String, location: CLLocation) async -> ApiResult<String>
    
    func fetchAroundStores(location: CLLocation, distance: Int) async -> ApiResult<[BossStoreSimpleResponse]>
    
    func editStore(storeId: String, request: BossStorePatchRequest) async -> ApiResult<String>
}

final class StoreRepositoryImpl: StoreRepository {
    func fetchMyStore() async -> ApiResult<BossStoreResponse> {
        return await StoreApi.fetchMyStore.asyncRequest()
    }
    
    func openStore(storeId: String, location: CLLocation) async -> ApiResult<String> {
        return await StoreApi.openStore(storeId: storeId, location: location).asyncRequest()
    }
    
    func closeStore(storeId: String) async -> ApiResult<String> {
        return await StoreApi.closeStore(storeId: storeId).asyncRequest()
    }
    
    func renewStore(storeId: String, location: CLLocation) async -> ApiResult<String> {
        return await StoreApi.renewStore(storeId: storeId, location: location).asyncRequest()
    }
    
    func fetchAroundStores(location: CLLocation, distance: Int) async -> ApiResult<[BossStoreSimpleResponse]> {
        return await StoreApi.fetchAroundStores(location: location, distance: distance).asyncRequest()
    }
    
    func editStore(storeId: String, request: BossStorePatchRequest) async -> ApiResult<String> {
        return await StoreApi.editStore(storeId: storeId, request: request).asyncRequest()
    }
}
