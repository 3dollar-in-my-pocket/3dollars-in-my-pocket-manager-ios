import Alamofire

protocol AuthRepository {
    func logout(request: BossLogOutRequest?) async -> ApiResult<String>
}

final class AuthRepositoryImpl: AuthRepository {
    func logout(request: BossLogOutRequest?) async -> ApiResult<String> {
        return await AuthApi.logout(request: request).asyncRequest()
    }
}
