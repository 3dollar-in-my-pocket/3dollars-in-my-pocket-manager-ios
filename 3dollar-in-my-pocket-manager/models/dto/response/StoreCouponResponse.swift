struct StoreCouponResponse: Decodable, Hashable {
    let couponId: String
    let name: String
    let maxIssuableCount: Int
    let currentIssuedCount: Int
    let currentUsedCount: Int
    let validityPeriod: DateTimeIntervalResponse
    let status: StoreCouponStatus
    let createdAt: String
    let updatedAt: String
}

struct DateTimeIntervalResponse: Decodable, Hashable {
    let startDateTime: String
    let endDateTime: String
}

enum StoreCouponStatus: String, Decodable {
    case active = "ACTIVE"
    case ended = "ENDED"
    case stopped = "STOPPED"
}
