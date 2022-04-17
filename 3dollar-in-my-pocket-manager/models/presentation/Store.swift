import CoreLocation
import Base

struct Store: Equatable {
    let id: String
    var location: CLLocation?
    var isOpen: Bool
    var openTime: Date?
    var imageUrl: String?
    var categories: [StoreCategory]
    var phoneNumber: String?
    var snsUrl: String?
    
    init(response: BossStoreInfoResponse) {
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
        self.imageUrl = response.imageUrl
        self.categories = response.categories.map(StoreCategory.init)
        self.phoneNumber = response.contactsNumber
        self.snsUrl = response.snsUrl
    }
    
    init(response: BossStoreAroundInfoResponse) {
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
        self.phoneNumber = nil
        self.snsUrl = nil
    }
    
    init(
        id: String = "",
        location: CLLocation = CLLocation(latitude: 0, longitude: 0),
        isOpen: Bool = false,
        openTime: Date? = nil,
        imageUrl: String? = nil,
        categories: [StoreCategory] = [],
        phoneNumber: String? = nil,
        snsUrl: String? = nil
    ) {
        self.id = id
        self.location = location
        self.isOpen = isOpen
        self.openTime = openTime
        self.imageUrl = imageUrl
        self.categories = categories
        self.phoneNumber = phoneNumber
        self.snsUrl = snsUrl
    }
}
