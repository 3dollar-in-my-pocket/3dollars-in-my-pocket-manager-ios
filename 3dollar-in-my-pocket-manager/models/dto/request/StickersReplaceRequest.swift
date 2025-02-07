import Foundation

struct StickersReplaceRequest: Encodable {
    let stickers: [StoreReviewStickerRequest]
}

struct StoreReviewStickerRequest: Encodable {
    let stickerId: String
}
