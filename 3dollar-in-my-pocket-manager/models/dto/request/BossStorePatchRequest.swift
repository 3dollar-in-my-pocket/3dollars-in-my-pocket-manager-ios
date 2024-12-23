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
    let contactsNumbers: [BossStoreContactsNumberRequest]?
    
    init(
        name: String? = nil,
        representativeImages: [BossStoreImage]? = nil,
        introduction: String? = nil,
        snsUrl: String? = nil,
        menus: [BossStoreMenu]? = nil,
        appearanceDays: [BossStoreAppearanceDayRequest]? = nil,
        categoriesIds: [String]? = nil,
        accountNumbers: [BossStoreAccountNumber]? = nil,
        contactsNumbers: [BossStoreContactsNumberRequest]? = nil
    ) {
        self.name = name
        self.representativeImages = representativeImages
        self.introduction = introduction
        self.snsUrl = snsUrl
        self.menus = menus
        self.appearanceDays = appearanceDays
        self.categoriesIds = categoriesIds
        self.accountNumbers = accountNumbers
        self.contactsNumbers = contactsNumbers
    }
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

struct BossStoreContactsNumberRequest: Encodable {
    let number: String
    let description: String?
    
    init(number: String, description: String? = nil) {
        self.number = number
        self.description = description
    }
}
