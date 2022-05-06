struct AppearanceDay: Equatable, Comparable {
    static func < (lhs: AppearanceDay, rhs: AppearanceDay) -> Bool {
        return lhs.index < rhs.index
    }
    
    var dayOfTheWeek: DayOfTheWeek
    var locationDescription: String
    var openingHours: TimeInterval
    
    init(response: BossStoreAppearanceDayResponse) {
        self.dayOfTheWeek = response.dayOfTheWeek
        self.locationDescription = response.locationDescription
        self.openingHours = response.openingHours
    }
    
    init(dayOfTheWeek: DayOfTheWeek) {
        self.dayOfTheWeek = dayOfTheWeek
        self.locationDescription = ""
        self.openingHours = TimeInterval()
    }
}

extension AppearanceDay {
    var index: Int {
        switch self.dayOfTheWeek {
        case .monday:
            return 0
            
        case .tuesday:
            return 1
            
        case .wednesday:
            return 2
            
        case .thursday:
            return 3
            
        case .friday:
            return 4
            
        case .saturday:
            return 5
            
        case .sunday:
            return 6
        }
    }
}
