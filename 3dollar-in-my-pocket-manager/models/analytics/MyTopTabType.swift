enum MyTopTabType {
    case myStoreInfo
    case statistics
    
    var name: String {
        switch self {
        case .myStoreInfo:
            return "myStoreInfo"
            
        case .statistics:
            return "statistics"
        }
    }
}
