import Foundation

struct ApiResponse<T: Decodable>: Decodable {
    let ok: Bool
    let error: ApiErrorType?
    let message: String?
    let data: T?
}

struct ApiErrorContainer: Decodable {
    let error: ApiErrorType?
    let message: String?
}
