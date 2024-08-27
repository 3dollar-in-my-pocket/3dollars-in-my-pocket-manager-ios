enum DayOfTheWeek: String, Codable, Equatable, Hashable {
    case monday = "MONDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
    case thursday = "THURSDAY"
    case friday = "FRIDAY"
    case saturday = "SATURDAY"
    case sunday = "SUNDAY"
    case unknown
    
    init(from decoder: Decoder) throws {
        self = try DayOfTheWeek(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

extension DayOfTheWeek {
    var index: Int {
        switch self {
        case .monday:
            return 0
            
        case .tuesday:
            return 1
            
        case .wednesday:
            return 2
            
        case .thursday:
            return 3
            
        case .friday:
            return 4
            
        case .saturday:
            return 5
            
        case .sunday:
            return 6
        
        case .unknown:
            return 0
        }
    }
    
    var fullText: String {
        switch self {
        case .monday:
            return "monday_full".localized
        case .tuesday:
            return "tuesday_full".localized
        case .wednesday:
            return "wednesday_full".localized
        case .thursday:
            return "thursday_full".localized
        case .friday:
            return "friday_full".localized
        case .saturday:
            return "saturday_full".localized
        case .sunday:
            return "sunday_full".localized
        case .unknown:
            return ""
        }
    }
}
