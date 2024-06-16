import Foundation

struct ApiResponse<T: Decodable>: Decodable {
    let ok: Bool
    let error: String?
    let message: String?
    let data: T?
}
