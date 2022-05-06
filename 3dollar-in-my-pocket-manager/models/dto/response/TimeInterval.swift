struct TimeInterval: Decodable, Equatable {
    var endTime: LocalTimeRes
    var startTime: LocalTimeRes
    
    enum CodingKeys: String, CodingKey {
        case endTime
        case startTime
    }
    
    init() {
        self.startTime = LocalTimeRes()
        self.endTime = LocalTimeRes()
    }
    
    init(
        endTime: LocalTimeRes = LocalTimeRes(),
        startTime: LocalTimeRes = LocalTimeRes()
    ) {
        self.endTime = endTime
        self.startTime = startTime
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.endTime = try values.decodeIfPresent(
            LocalTimeRes.self,
            forKey: .endTime
        ) ?? LocalTimeRes()
        self.startTime = try values.decodeIfPresent(
            LocalTimeRes.self,
            forKey: .startTime
        ) ?? LocalTimeRes()
    }
}
