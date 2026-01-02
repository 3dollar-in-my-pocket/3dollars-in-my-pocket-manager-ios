import Alamofire

protocol AppRepository {
    func fetchAppStatus() async -> ApiResult<AppStatusResponse>
}

final class AppRepositoryImpl: AppRepository {
    func fetchAppStatus() async -> ApiResult<AppStatusResponse> {
        return await AppApi.fetchAppStatus.asyncRequest()
    }
}
