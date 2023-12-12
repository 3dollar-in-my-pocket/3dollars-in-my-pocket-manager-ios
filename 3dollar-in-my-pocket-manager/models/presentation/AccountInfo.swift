import Foundation

struct AccountInfo: Equatable {
    let bank: String
    let holder: String
    let number: String
    let description: String?
    
    init(response: StoreAccountNumberResponse) {
        self.bank = response.bank.description
        self.holder = response.accountHolder
        self.number = response.accountNumber
        self.description = response.description
    }
    
    init(bank: String, number: String, holder: String = "", description: String? = nil) {
        self.bank = bank
        self.number = number
        self.holder = holder
        self.description = description
    }
}
