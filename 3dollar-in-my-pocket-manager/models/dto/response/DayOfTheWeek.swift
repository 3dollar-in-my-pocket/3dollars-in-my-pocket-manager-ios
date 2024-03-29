enum DayOfTheWeek: String, Codable, Equatable {
    case monday = "MONDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
    case thursday = "THURSDAY"
    case friday = "FRIDAY"
    case saturday = "SATURDAY"
    case sunday = "SUNDAY"
    
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
        }
    }
}
