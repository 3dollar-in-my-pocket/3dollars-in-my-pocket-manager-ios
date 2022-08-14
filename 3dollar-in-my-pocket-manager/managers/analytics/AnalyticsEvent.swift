import Foundation

enum AnalyticsEvent {
    case setUserId(String)
    case viewScreen(AnalyticsScreen)
    case signin(userId: String, screen: AnalyticsScreen)
    case signup(userId: String, screen: AnalyticsScreen)
    case tapEmail(screen: AnalyticsScreen)
    case logout(userId: String, screen: AnalyticsScreen)
    case showOtherBoss(isOn: Bool, screen: AnalyticsScreen)
    case tapBottomTab(tab: BottomTabType)
    case tapMyTopTab(tab: MyTopTabType)
    case tapEditStoreInfo(storeId: String, screen: AnalyticsScreen)
    case tapEditIntroduction(storeId: String, screen: AnalyticsScreen)
    case tapEditMenu(storeId: String, screen: AnalyticsScreen)
    case tapEditSchedule(storeId: String, screen: AnalyticsScreen)
    case editStoreInfo(storeId: String, screen: AnalyticsScreen)
    case editStoreIntroduction(storeId: String, screen: AnalyticsScreen)
    case editStoreMenu(storeId: String, screen: AnalyticsScreen)
    case errorInEditingMenu(storeId: String, screen: AnalyticsScreen)
    case editSchedule(storeId: String, screen: AnalyticsScreen)
    case tapStatisticTab(filterType: StatisticsFilterButton.FilterType)
    case signout(userId: String)
    
    var eventName: String {
        switch self {
        case .setUserId:
            return ""
            
        case .viewScreen:
            return ""
            
        case .signin:
            return "signin"
            
        case .signup:
            return "signUp"
            
        case .tapEmail:
            return "tapEmail"
            
        case .logout:
            return "logout"
            
        case .showOtherBoss:
            return "showOtherBoss"
            
        case .tapBottomTab:
            return "tabBottomTab"
            
        case .tapMyTopTab:
            return "tapMyTopTab"
            
        case .tapEditStoreInfo:
            return "tapEditStoreInfo"
            
        case .tapEditIntroduction:
            return "tapEditIntroduction"
            
        case .tapEditMenu:
            return "tapEditMenu"
            
        case .tapEditSchedule:
            return "tapEditSchedule"
            
        case .editStoreInfo:
            return "editStoreInfo"
            
        case .editStoreIntroduction:
            return "editStoreIntroduction"
            
        case .editStoreMenu:
            return "editStoreMenu"
            
        case .errorInEditingMenu:
            return "errorInEditingMenu"
            
        case .editSchedule:
            return "editSchedule"
            
        case .tapStatisticTab:
            return "tapStatisticTab"
            
        case .signout:
            return "signout"
        }
    }
}
