enum DeeplinkPath: String {
    case reviewList
    case unknown
    
    init(value: String) {
        self = DeeplinkPath(rawValue: value) ?? .unknown
    }
}

extension DeeplinkPath {
    var path: String {
        rawValue
    }
}
