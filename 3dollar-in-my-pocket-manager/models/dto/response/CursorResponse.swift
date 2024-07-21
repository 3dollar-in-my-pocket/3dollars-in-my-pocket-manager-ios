struct CursorResponse: Decodable {
    let hasMore: Bool
    let nextCursor: String?
    
    init() {
        self.hasMore = false
        self.nextCursor = nil
    }
}
