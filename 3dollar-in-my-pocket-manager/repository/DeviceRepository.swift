import Alamofire

protocol DeviceRepository {
    func registerDevice(fcmToken: String) async -> ApiResult<String>
}

final class DeviceRepositoryImpl: DeviceRepository {
    func registerDevice(fcmToken: String) async -> ApiResult<String> {
        #if targetEnvironment(simulator)
        return .success("")
        #else
        return await DeviceApi.register(fcmToken: fcmToken).asyncRequest()
        #endif
    }
}
