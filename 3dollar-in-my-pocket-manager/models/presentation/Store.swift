import CoreLocation
import Base

struct Store: Equatable {
    let id: String
    var location: CLLocation?
    var isOpen: Bool
    var openTime: Date?
    
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
    }
    
    init(
        id: String = "",
        location: CLLocation = CLLocation(latitude: 0, longitude: 0),
        isOpen: Bool = false,
        openTime: Date? = nil
    ) {
        self.id = id
        self.location = location
        self.isOpen = isOpen
        self.openTime = openTime
    }
}
