struct BossStoreAppearanceDayResponse: Decodable {
    let dayOfTheWeek: DayOfTheWeek
    let locationDescription: String
    let openingHours: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case dayOfTheWeek
        case locationDescription
        case openingHours
    }
    
    init(
        dayOfTheWeek: DayOfTheWeek = .sunday,
        locationDescription: String = "",
        openingHours: TimeInterval = TimeInterval()
    ) {
        self.dayOfTheWeek = dayOfTheWeek
        self.locationDescription = locationDescription
        self.openingHours = openingHours
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.dayOfTheWeek = try values.decodeIfPresent(
            DayOfTheWeek.self,
            forKey: .dayOfTheWeek
        ) ?? .sunday
        self.locationDescription = try values.decodeIfPresent(
            String.self,
            forKey: .locationDescription
        ) ?? ""
        self.openingHours = try values.decodeIfPresent(
            TimeInterval.self,
            forKey: .openingHours
        ) ?? TimeInterval()
    }
}
