struct BossStoreOpenStatusResponse: Decodable {
    var openStartDateTime: String?
    var status: OpenStatus
}
