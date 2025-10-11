struct StoreCouponResponse: Decodable {
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

struct DateTimeIntervalResponse: Decodable {
    let startDateTime: String
    let endDateTime: String
}

enum StoreCouponStatus: String, Decodable {
    case active = "ACTIVE"
    case ended = "ENDED"
}
