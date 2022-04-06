struct BossStoreOpenStatusResponse: Decodable {
    let openStartDateTime: String
    let status: OpenStatus
    
    enum CodingKeys: String, CodingKey {
        case openStartDateTime
        case status
    }
    
    init(
        openStartDateTime: String = "",
        status: OpenStatus = .closed
    ) {
        self.openStartDateTime = openStartDateTime
        self.status = status
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.openStartDateTime = try values.decodeIfPresent(String.self, forKey: .openStartDateTime) ?? ""
        self.status = try values.decodeIfPresent(OpenStatus.self, forKey: .status) ?? .closed
    }
}
