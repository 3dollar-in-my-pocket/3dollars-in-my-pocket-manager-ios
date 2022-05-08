import Foundation

struct AppearanceDayRequest: Encodable {
    let dayOfTheWeek: DayOfTheWeek
    let endTime: String
    let locationDescription: String?
    let startTime: String
    
    enum CodingKeys: String, CodingKey {
        case dayOfTheWeek
        case endTime
        case locationDescription
        case startTime
    }
    
    init(appearance: AppearanceDay) {
        self.dayOfTheWeek = appearance.dayOfTheWeek
        self.endTime = appearance.openingHours.endTime
        self.locationDescription = appearance.locationDescription
        self.startTime = appearance.openingHours.startTime
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.dayOfTheWeek, forKey: .dayOfTheWeek)
        try container.encode(self.endTime, forKey: .endTime)
        try container.encodeIfPresent(self.locationDescription, forKey: .locationDescription)
        try container.encode(self.startTime, forKey: .startTime)
    }
}
