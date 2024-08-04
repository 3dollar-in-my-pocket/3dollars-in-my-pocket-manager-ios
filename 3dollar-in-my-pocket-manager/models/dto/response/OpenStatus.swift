enum OpenStatus: String, Decodable {
    case closed  = "CLOSED"
    case open = "OPEN"
    case unknown
    
    init(from decoder: Decoder) throws {
        self = try OpenStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
