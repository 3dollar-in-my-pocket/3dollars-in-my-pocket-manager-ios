import Alamofire

protocol PreferenceRepository {
    func fetchPreference(storeId: String) async -> ApiResult<StorePreferenceResponse>
    
    func updatePreference(
        storeId: String,
        storePreferencePatchRequest: StorePreferencePatchRequest
    ) async -> ApiResult<String>
}


final class PreferenceRepositoryImpl: PreferenceRepository {
    func fetchPreference(storeId: String) async -> ApiResult<StorePreferenceResponse> {
        return await PreferenceApi.fetchPreference(storeId: storeId).asyncRequest()
    }
    
    func updatePreference(storeId: String, storePreferencePatchRequest: StorePreferencePatchRequest) async -> ApiResult<String> {
        return await PreferenceApi.updatePreference(
            storeId: storeId,
            storePreferencePatchRequest: storePreferencePatchRequest
        ).asyncRequest()
    }
}
