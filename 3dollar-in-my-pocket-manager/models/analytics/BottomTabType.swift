enum BottomTabType {
    case home
    case my
    case setting
    
    var name: String {
        switch self {
        case .home:
            return "home"
            
        case .my:
            return "my"
            
        case .setting:
            return "setting"
        }
    }
}
