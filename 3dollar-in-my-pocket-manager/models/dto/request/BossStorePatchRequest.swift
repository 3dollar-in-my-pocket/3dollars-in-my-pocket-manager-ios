import Foundation

struct BossStorePatchRequest: Encodable {
    let name: String?
    let representativeImages: [BossStoreImage]?
    let introduction: String?
    let snsUrl: String?
    let menus: [BossStoreMenu]?
    let appearanceDays: [BossStoreAppearanceDayRequest]?
    let categoriesIds: [String]?
    let accountNumbers: [BossStoreAccountNumber]?
}

struct BossStoreAppearanceDayRequest: Encodable {
    let dayOfTheWeek: DayOfTheWeek
    let startTime: String
    let endTime: String
    let locationDescription: String
    
    init(
        dayOfTheWeek: DayOfTheWeek,
        startTime: String,
        endTime: String,
        locationDescription: String
    ) {
        self.dayOfTheWeek = dayOfTheWeek
        self.startTime = startTime
        self.endTime = endTime
        self.locationDescription = locationDescription
    }
    
    init(response: BossStoreAppearanceDayResponse) {
        self.dayOfTheWeek = response.dayOfTheWeek
        self.startTime = response.openingHours.startTime
        self.endTime = response.openingHours.endTime
        self.locationDescription = response.locationDescription
    }
}
