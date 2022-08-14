enum PushType: String {
    case background = "BACKGROUND"
    case push = "PUSH"
    case unknown
    
    init(rawValue: String) {
        switch rawValue {
        case PushType.background.rawValue:
            self = .background
            
        case PushType.push.rawValue:
            self = .push
            
        default:
            self = .unknown
        }
    }
}
