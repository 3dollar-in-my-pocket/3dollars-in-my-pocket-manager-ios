struct TimeInterval: Decodable {
    var endTime: String
    var startTime: String
    
    enum CodingKeys: String, CodingKey {
        case endTime
        case startTime
    }
    
    init() {
        self.startTime = ""
        self.endTime = ""
    }
    
    init(
        endTime: String = "",
        startTime: String = ""
    ) {
        self.endTime = endTime
        self.startTime = startTime
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.endTime = try values.decodeIfPresent(String.self, forKey: .endTime) ?? ""
        self.startTime = try values.decodeIfPresent(String.self, forKey: .startTime) ?? ""
    }
}
