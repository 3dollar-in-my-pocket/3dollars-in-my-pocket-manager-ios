import FirebaseAnalytics

final class GAManager: AnalyticsManagerProtocol {
    static let shared = GAManager()
    
    func sendEvent(event: AnalyticsEvent) {
        switch event {
        case .setUserId(let userId):
            Analytics.setUserID(userId)
            
        case .viewScreen(let analyticsScreen):
            Analytics.logEvent(
                AnalyticsEventScreenView,
                parameters: [
                    AnalyticsParameterScreenName: analyticsScreen.screenName,
                    AnalyticsParameterScreenClass: analyticsScreen.screenClass
                ])
            
        case .signin(let userId, let screen):
            Analytics.logEvent(
                event.eventName,
                parameters: [
                    "userId": userId,
                    "screen": screen.screenName
                ]
            )
            
        case .signup(let userId, let screen):
            Analytics.logEvent(
                event.eventName,
                parameters: [
                    "userId": userId,
                    "screen": screen.screenName
                ]
            )
            
        case .tapEmail(let screen):
            Analytics.logEvent(event.eventName, parameters: ["screen": screen.screenName])
            
        case .logout(let userId, let screen):
            Analytics.logEvent(
                event.eventName,
                parameters: [
                    "userId": userId,
                    "screen": screen.screenName
                ]
            )
            
        case .showOtherBoss(let isOn, let screen):
            Analytics.logEvent(
                event.eventName,
                parameters: [
                    "isOn": isOn,
                    "screen": screen.screenName
                ]
            )
            
        case .tapBottomTab(let tab):
            Analytics.logEvent(
                event.eventName,
                parameters: ["tab": tab.name]
            )
            
        case .tapMyTopTab(let tab):
            Analytics.logEvent(
                event.eventName,
                parameters: ["tab": tab.name]
            )
            
        case .tapEditStoreInfo(let storeId, let screen):
            Analytics.logEvent(
                event.eventName,
                parameters: [
                    "storeId": storeId,
                    "screen": screen.screenName
                ]
            )
            
        case .tapEditMenu(let storeId, let screen):
            Analytics.logEvent(
                event.eventName,
                parameters: [
                    "storeId": storeId,
                    "screen": screen.screenName
                ]
            )
            
        case .tapEditSchedule(let storeId, let screen):
            Analytics.logEvent(
                event.eventName,
                parameters: [
                    "storeId": storeId,
                    "screen": screen.screenName
                ]
            )
            
        case .editStoreInfo(let storeId, let screen):
            Analytics.logEvent(
                event.eventName,
                parameters: [
                    "storeId": storeId,
                    "screen": screen.screenName
                ]
            )
            
        case .editStoreIntroduction(let storeId, let screen):
            Analytics.logEvent(
                event.eventName,
                parameters: [
                    "storeId": storeId,
                    "screen": screen.screenName
                ]
            )
            
        case .editStoreMenu(let storeId, let screen):
            Analytics.logEvent(
                event.eventName,
                parameters: [
                    "storeId": storeId,
                    "screen": screen.screenName
                ]
            )
            
        case .errorInEditingMenu(let storeId, let screen):
            Analytics.logEvent(
                event.eventName,
                parameters: [
                    "storeId": storeId,
                    "screen": screen.screenName
                ]
            )
            
        case .editSchedule(let storeId, let screen):
            Analytics.logEvent(
                event.eventName,
                parameters: [
                    "storeId": storeId,
                    "screen": screen.screenName
                ]
            )
            
        case .tapStatisticTab(let storeId):
            Analytics.logEvent(event.eventName, parameters: ["storeId": storeId])
            
        case .signout(let userId):
            Analytics.logEvent(event.eventName, parameters: ["userId": userId])
            
        case .tapEditIntroduction(storeId: let storeId, screen: let screen):
            Analytics.logEvent(
                event.eventName,
                parameters: [
                    "storeId": storeId,
                    "screen": screen.screenName
                ]
            )
        }
    }
}
