import Foundation

enum EventName: String {
    case signin
    case signup
    case tapEmail
    case logout
    case showOtherBoss
    case tapBottomTab
    case tapMyTopTab
    case tapEditStoreInfo
    case tapEditIntroduction
    case tapEditMenu
    case tapEditSchedule
    case editStoreInfo
    case editStoreIntroduction
    case editStoreMenu
    case errorInEditingMenu
    case editSchedule
    case tapStatisticTab
    case signout
    
    
    
//    var parameters: [String: Any] {
//        switch self {
//        case .signin(let userId):
//            return ["userId": userId]
//        case .signup(let userId):
//            return ["userId": userId]
//        case .tapEmail:
//            return [:]
//        case .logout(let userId):
//            return ["userId": userId]
//        case .showOtherBoss(let isOn):
//            return ["isOn": isOn]
//        case .tapBottomTab(let tab):
//            return ["tab": tab.name]
//        case .tapMyTopTab(let tab):
//            return ["tab": tab.name]
//        case .tapEditStoreInfo(let storeId):
//            return ["storeId": storeId]
//        case .tapEditIntroduction(let storeId):
//            return ["storeId": storeId]
//        case .tapEditMenu(let storeId):
//            return ["storeId": storeId]
//        case .tapEditSchedule(let storeId):
//            return ["storeId": storeId]
//        case .editStoreInfo(let storeId):
//            return ["storeId": storeId]
//        case .editStoreIntroduction(let storeId):
//            return ["storeId": storeId]
//        case .editStoreMenu(let storeId):
//            return ["storeId": storeId]
//        case .errorInEditingMenu(let storeId):
//            return ["storeId": storeId]
//        case .editSchedule(let storeId):
//            return ["storeId": storeId]
//        case .tapStatisticTab(let filterType):
//            return ["filterType": filterType]
//        case .signout(let userId):
//            return ["userId": userId]
//        }
//    }
}
