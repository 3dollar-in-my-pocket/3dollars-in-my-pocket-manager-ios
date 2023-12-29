import Foundation

struct EnumResponse: Decodable {
    let Bank: [BankResponse]
}
