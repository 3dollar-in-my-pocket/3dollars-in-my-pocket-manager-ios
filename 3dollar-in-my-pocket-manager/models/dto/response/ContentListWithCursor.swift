import Foundation

struct ContentListWithCursor<T: Decodable>: Decodable {
    let contents: [T]
    let cursor: CursorString
}
