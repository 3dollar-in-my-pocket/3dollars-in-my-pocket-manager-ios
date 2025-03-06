import Foundation

struct ContentListWithCursorAndCount<T: Decodable & Hashable>: Decodable, Hashable {
    var contents: [T]
    let cursor: CursorAndCountString
}

struct CursorAndCountString: Decodable, Hashable {
    let nextCursor: String?
    let hasMore: Bool
    let totalCount: Int
}
