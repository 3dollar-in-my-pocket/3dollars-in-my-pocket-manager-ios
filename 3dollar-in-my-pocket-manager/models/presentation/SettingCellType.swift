enum SettingCellType {
    case registerationNumber(String)
    case contact
    case faq
    case privacy
    case signout(SocialType)
    
    var title: String {
        switch self {
        case .registerationNumber:
            return "setting_registeration_number".localized
            
        case .contact:
            return "setting_contact".localized
            
        case .faq:
            return "setting_faq".localized
            
        case .privacy:
            return "setting_privacy".localized
            
        case .signout:
            return ""
        }
    }
    
    static func toSettingCellTypes(user: User) -> [SettingCellType] {
        return [
            .registerationNumber(user.businessNumber),
            .contact,
            .faq,
            .privacy,
            .signout(user.socialType)
        ]
    }
}
