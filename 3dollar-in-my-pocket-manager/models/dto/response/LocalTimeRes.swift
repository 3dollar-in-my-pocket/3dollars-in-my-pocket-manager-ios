struct LocalTimeRes: Decodable {
    let hour: Int
    let minute: Int
    let nano: Int
    let second: Int
    
    enum CodingKeys: String, CodingKey {
        case hour
        case minute
        case nano
        case second
    }
    
    init(
        hour: Int = 0,
        minute: Int = 0,
        nano: Int = 0,
        second: Int = 0
    ) {
        self.hour  = hour
        self.minute = minute
        self.nano = nano
        self.second = second
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.hour = try values.decodeIfPresent(Int.self, forKey: .hour) ?? 0
        self.minute = try values.decodeIfPresent(Int.self, forKey: .minute) ?? 0
        self.nano = try values.decodeIfPresent(Int.self, forKey: .nano) ?? 0
        self.second = try values.decodeIfPresent(Int.self, forKey: .second) ?? 0
    }
}
