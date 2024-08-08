import Foundation

struct StoreAccountNumberResponse: Decodable, Hashable {
    let bank: BankResponse
    let accountHolder: String
    let accountNumber: String
    let description: String?
}
