struct AppearanceDay: Equatable {
    let dayOfTheWeek: DayOfTheWeek
    let locationDescription: String
    let openingHours: TimeInterval
    
    init(response: BossStoreAppearanceDayResponse) {
        self.dayOfTheWeek = response.dayOfTheWeek
        self.locationDescription = response.locationDescription
        self.openingHours = response.openingHours
    }
}
