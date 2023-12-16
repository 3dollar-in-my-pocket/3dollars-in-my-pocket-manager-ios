import Foundation

struct AccountInfo: Equatable {
    let bank: Bank
    let holder: String
    let number: String
    let description: String?
    
    init(response: StoreAccountNumberResponse) {
        self.bank = Bank(response: response.bank)
        self.holder = response.accountHolder
        self.number = response.accountNumber
        self.description = response.description
    }
    
    init(bank: Bank, number: String, holder: String = "", description: String? = nil) {
        self.bank = bank
        self.number = number
        self.holder = holder
        self.description = description
    }
}
