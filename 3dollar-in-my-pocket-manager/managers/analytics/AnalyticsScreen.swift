enum AnalyticsScreen {
    case signin
    case signup
    case waiting
    case home
    case myStoreInfo
    case statistics
    case editStoreInfo
    case editIntroduction
    case editMenu
    case editSchedule
    case setting
    case faq
    
    var screenName: String {
        switch self {
        case .signin:
            return "signin"
            
        case .signup:
            return "signup"
            
        case .waiting:
            return "waiting"
            
        case .home:
            return "home"
            
        case .myStoreInfo:
            return "myStoreInfo"
            
        case .statistics:
            return "statistics"
            
        case .editStoreInfo:
            return "editStoreInfo"
            
        case .editIntroduction:
            return "editIntroduction"
            
        case .editMenu:
            return "editMenu"
            
        case .editSchedule:
            return "editSchedule"
            
        case .setting:
            return "setting"
            
        case .faq:
            return "faq"
        }
    }
    
    var screenClass: String {
        switch self {
        case .signin:
            return "SigninViewController"
            
        case .signup:
            return "SignupViewController"
            
        case .waiting:
            return "waitingViewController"
            
        case .home:
            return "HomeViewController"
            
        case .myStoreInfo:
            return "MyStoreInfoViewController"
            
        case .statistics:
            return "StatisticsViewController"
            
        case .editStoreInfo:
            return "EditStoreInfoViewController"
            
        case .editIntroduction:
            return "EditIntroductionViewController"
            
        case .editMenu:
            return "EditMenuViewController"
            
        case .editSchedule:
            return "EditScheduleViewContrller"
            
        case .setting:
            return "SettingViewContrller"
            
        case .faq:
            return "FAQViewContrller"
        }
    }
}
