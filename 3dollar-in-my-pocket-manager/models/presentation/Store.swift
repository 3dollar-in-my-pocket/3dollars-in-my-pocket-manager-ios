import CoreLocation

struct Store: Equatable {
    let id: String
    var location: CLLocation?
    var isOpen: Bool
    var openTime: Date?
    var imageUrl: String?
    var categories: [StoreCategory]
    var snsUrl: String?
    var introduction: String?
    var menus: [Menu]
    var name: String
    var appearanceDays: [AppearanceDay]
    var accountInfos: [AccountInfo]
    
    var isValid: Bool {
        return !(self.imageUrl ?? "").isEmpty
        && !(self.imageUrl ?? "").isEmpty
        && !self.name.isEmpty
    }
    
    init(response: BossStoreResponse) {
        self.id = response.bossStoreId
        if let location = response.location {
            self.location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        } else {
            self.location = nil
        }
        self.isOpen = response.openStatus.status == .open
        
        if let openStartDateTime = response.openStatus.openStartDateTime {
            self.openTime = DateUtils.toDate(dateString: openStartDateTime)
        } else {
            self.openTime = nil
        }
        self.imageUrl = response.representativeImages.first?.imageUrl
        self.categories = response.categories.map(StoreCategory.init)
        self.snsUrl = response.snsUrl
        self.introduction = response.introduction
        self.menus = response.menus.map(Menu.init)
        self.name = response.name
        self.appearanceDays = response.appearanceDays.map(AppearanceDay.init)
        self.accountInfos = response.accountNumbers.map({ AccountInfo(response: $0) })
    }
    
    init(response: BossStoreSimpleResponse) {
        self.id = response.bossStoreId
        if let location = response.location {
            self.location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        } else {
            self.location = nil
        }
        self.isOpen = response.openStatus.status == .open
        
        if let openStartDateTime = response.openStatus.openStartDateTime {
            self.openTime = DateUtils.toDate(dateString: openStartDateTime)
        } else {
            self.openTime = nil
        }
        self.imageUrl = nil
        self.categories = response.categories.map(StoreCategory.init)
        self.snsUrl = nil
        self.introduction = nil
        self.menus = response.menus.map(Menu.init)
        self.name = response.name
        self.appearanceDays = []
        self.accountInfos = []
    }
    
    init(
        id: String = "",
        location: CLLocation = CLLocation(latitude: 0, longitude: 0),
        isOpen: Bool = false,
        openTime: Date? = nil,
        imageUrl: String? = nil,
        categories: [StoreCategory] = [],
        snsUrl: String? = nil,
        introduction: String? = nil,
        menus: [Menu] = [],
        name: String = "",
        appearanceDays: [AppearanceDay] = [],
        accountInfos: [AccountInfo] = []
    ) {
        self.id = id
        self.location = location
        self.isOpen = isOpen
        self.openTime = openTime
        self.imageUrl = imageUrl
        self.categories = categories
        self.snsUrl = snsUrl
        self.introduction = introduction
        self.menus = menus
        self.name = name
        self.appearanceDays = appearanceDays
        self.accountInfos = accountInfos
    }
}
