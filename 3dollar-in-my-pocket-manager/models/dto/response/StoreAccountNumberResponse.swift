import Foundation

struct StoreAccountNumberResponse: Decodable {
    let bank: BackResponse
    let accountHolder: String
    let accountNumber: String
    let description: String?
}
