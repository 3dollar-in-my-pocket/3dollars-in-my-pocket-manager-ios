import Foundation

struct Menu: Equatable {
    let imageUrl: String
    let name: String
    let price: Int
    
    init(response: BossStoreMenuResponse) {
        self.imageUrl = response.imageUrl
        self.name = response.name
        self.price = response.price
    }
    
    init() {
        self.imageUrl = ""
        self.name = ""
        self.price = 0
    }
}
