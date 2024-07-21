import Foundation

enum ActivitiesStatus: String, Decodable {
    case recentActivity = "RECENT_ACTIVITY"
    case noRecentActivity = "NO_RECENT_ACTIVITY"
    case unknown
    
    init(from decoder: Decoder) throws {
        self = try ActivitiesStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
