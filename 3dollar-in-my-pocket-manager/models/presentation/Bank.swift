import Foundation

struct Bank: Equatable {
    let key: String
    let description: String
    
    init(response: BossBank) {
        self.key = response.key
        self.description = response.description
    }
    
    init(key: String, description: String) {
        self.key = key
        self.description = description
    }
}
