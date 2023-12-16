import Foundation

struct StoreAccountNumberResponse: Decodable {
    let bank: BankResponse
    let accountHolder: String
    let accountNumber: String
    let description: String?
}
