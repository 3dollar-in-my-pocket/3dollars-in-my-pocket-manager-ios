import Foundation

struct Bank: Equatable {
    let key: String
    let description: String
    
    init(response: BankResponse) {
        self.key = response.key
        self.description = response.description
    }
    
    init(key: String, description: String) {
        self.key = key
        self.description = description
    }
}
