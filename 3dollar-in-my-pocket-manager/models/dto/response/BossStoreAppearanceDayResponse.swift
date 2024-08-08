struct BossStoreAppearanceDayResponse: Decodable, Hashable {
    let dayOfTheWeek: DayOfTheWeek
    let locationDescription: String
    let openingHours: OperatingHours
    
    /// UI 에서만 사용하는 필드
    var isClosedDay: Bool
    
    enum CodingKeys: String, CodingKey {
        case dayOfTheWeek
        case locationDescription
        case openingHours
    }
    
    init(
        dayOfTheWeek: DayOfTheWeek = .sunday,
        locationDescription: String = "",
        openingHours: OperatingHours = OperatingHours(),
        isClosedDay: Bool = true
    ) {
        self.dayOfTheWeek = dayOfTheWeek
        self.locationDescription = locationDescription
        self.openingHours = openingHours
        self.isClosedDay = isClosedDay
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        dayOfTheWeek = try values.decodeIfPresent(
            DayOfTheWeek.self,
            forKey: .dayOfTheWeek
        ) ?? .sunday
        locationDescription = try values.decodeIfPresent(
            String.self,
            forKey: .locationDescription
        ) ?? ""
        openingHours = try values.decodeIfPresent(
            OperatingHours.self,
            forKey: .openingHours
        ) ?? OperatingHours()
        isClosedDay = false
    }
}
