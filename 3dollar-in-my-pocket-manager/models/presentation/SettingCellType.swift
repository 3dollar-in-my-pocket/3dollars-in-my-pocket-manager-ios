enum SettingCellType {
    case registerationNumber(String)
    case contact
    case notification(isEnable: Bool)
    case faq
    case privacy
    case signout(SocialType)
    
    var title: String {
        switch self {
        case .registerationNumber:
            return "setting_registeration_number".localized
            
        case .contact:
            return "setting_contact".localized
            
        case .notification:
            return "setting_notification".localized
            
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
            .notification(isEnable: user.isNotificationEnable),
            .contact,
            .faq,
            .privacy,
            .signout(user.socialType)
        ]
    }
}
