struct BossStoreOpenStatusResponse: Decodable, Hashable {
    var openStartDateTime: String?
    var status: OpenStatus
}
