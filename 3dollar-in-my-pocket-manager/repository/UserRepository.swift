import Alamofire

protocol UserRepository {
    func fetchUser() async -> ApiResult<BossWithSettingsResponse>
}

final class UserRepositoryImpl: UserRepository {
    func fetchUser() async -> ApiResult<BossWithSettingsResponse> {
        return await UserApi.fetchUser.asyncRequest()
    }
}
