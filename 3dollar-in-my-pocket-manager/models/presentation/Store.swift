import CoreLocation
import Base

struct Store: Equatable {
    let id: String
    let location: CLLocation?
    var isOpen: Bool
    let openTime: Date?
    
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
}
