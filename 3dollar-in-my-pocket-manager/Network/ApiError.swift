import Foundation

enum ApiError: Error {
    case decodingError
    case serverError(String)
    case emptyData
    case errorContainer(ApiErrorContainer)
}
