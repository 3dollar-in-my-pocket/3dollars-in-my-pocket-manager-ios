import Foundation

struct Menu: Equatable {
    var imageUrl: String
    var name: String
    var price: Int
    
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
