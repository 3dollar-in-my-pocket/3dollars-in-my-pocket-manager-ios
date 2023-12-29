import Foundation

struct TimeInterval: Decodable, Equatable {
    var endTime: String
    var startTime: String
    
    enum CodingKeys: String, CodingKey {
        case endTime
        case startTime
    }
    
    init(
        endTime: String = DateUtils.toString(date: Date(), format: "HH:mm"),
        startTime: String = DateUtils.toString(date: Date(), format: "HH:mm")
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
