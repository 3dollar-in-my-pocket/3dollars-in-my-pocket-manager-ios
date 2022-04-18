import Foundation

struct LocalTimeReq: Encodable {
    let hour: String?
    let minute: String?
    let nano: Int?
    let second: String?
    
    enum CodingKeys: String, CodingKey {
        case hour
        case minute
        case nano
        case second
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(self.hour, forKey: .hour)
        try container.encodeIfPresent(self.minute, forKey: .minute)
        try container.encodeIfPresent(self.nano, forKey: .nano)
        try container.encodeIfPresent(self.second, forKey: .second)
    }
}
