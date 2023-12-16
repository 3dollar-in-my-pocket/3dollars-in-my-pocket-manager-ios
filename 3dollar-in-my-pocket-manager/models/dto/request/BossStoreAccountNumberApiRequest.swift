import Foundation

struct BossStoreAccountNumberApiRequest: Encodable {
    let bank: String
    let accountHolder: String
    let accountNumber: String
    let description: String?
    
    init?(_ accountInfo: AccountInfo?) {
        guard let accountInfo else { return nil }
        self.bank = accountInfo.bank.key
        self.accountHolder = accountInfo.holder
        self.accountNumber = accountInfo.number
        self.description = accountInfo.description
    }
}
