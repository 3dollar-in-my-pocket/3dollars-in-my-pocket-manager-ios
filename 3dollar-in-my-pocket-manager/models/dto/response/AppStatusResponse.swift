struct AppStatusResponse: Decodable {
    let osPlatform: String
    let currentVersion: String
    let forceUpdate: AppForceUpdateResponse
}
