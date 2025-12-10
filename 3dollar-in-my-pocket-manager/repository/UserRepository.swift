import Alamofire

protocol UserRepository {
    func fetchUser() async -> ApiResult<BossWithSettingsResponse>
    
    func updateAccountSettings(input: BossSettingPatchRequest) async -> ApiResult<String>
}

final class UserRepositoryImpl: UserRepository {
    func fetchUser() async -> ApiResult<BossWithSettingsResponse> {
        return await UserApi.fetchUser.asyncRequest()
    }
    
    func updateAccountSettings(input: BossSettingPatchRequest) async -> ApiResult<String> {
        return await UserApi.updateAccountSettings(input: input).asyncRequest()
    }
}
