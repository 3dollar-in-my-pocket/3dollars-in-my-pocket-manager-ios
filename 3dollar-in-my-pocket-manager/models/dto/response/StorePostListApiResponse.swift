import Foundation

struct StorePostListApiResponse: Decodable {
    let contents: [StorePostApiResponse]
    let cursor: CursorResponse
}
