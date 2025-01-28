import Foundation

struct ContentListWithCursor<T: Decodable>: Decodable {
    let contents: [T]
    let cursor: CursorString
}

struct CursorString: Decodable {
    let hasMore: Bool
    let nextCursor: String?
}
