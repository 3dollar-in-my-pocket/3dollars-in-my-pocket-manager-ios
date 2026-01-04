struct AppForceUpdateResponse: Decodable {
    let enabled: Bool
    let title: String?
    let message: String?
    let linkUrl: String?
}
