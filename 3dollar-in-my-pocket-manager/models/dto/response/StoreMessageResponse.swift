import Foundation

struct StoreMessageResponse: Decodable, Hashable {
    let messageId: String
    let body: String
    let isOwner: Bool
    let createdAt: String
    let updatedAt: String
}

struct StoreMessageListResponse: Decodable {
    let messages: ContentListWithCursor<StoreMessageResponse>
    let policy: StoreMessagePolicyResponse
}

struct ContentListWithCursorStoreMessageResponse: Decodable {
    let contents: [StoreMessageResponse]
    let cursor: CursorString
}

struct StoreMessagePolicyResponse: Decodable {
    let dailyLimit: Int
    let canSendNow: Bool
    let nextAvailableSendDateTime: String
}
