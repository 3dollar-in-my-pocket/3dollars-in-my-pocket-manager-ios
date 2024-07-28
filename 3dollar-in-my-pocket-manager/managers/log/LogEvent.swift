import Foundation

struct LogEvent {
    let screen: ScreenName
    let name: EventName
    let extraParameters: [ParameterName: Any]?
    
    init(
        screen: ScreenName,
        eventName: EventName,
        extraParameters: [ParameterName : Any]? = nil
    ) {
        self.screen = screen
        self.name = eventName
        self.extraParameters = extraParameters
    }
    
    var parameters: [String: Any] {
        var result: [String: Any] = [:]
        
        if let extraParameters {
            extraParameters.forEach { key, value in
                result[key.rawValue] = value
            }
        }
        
        result[ParameterName.screen.rawValue] = screen.rawValue
        return result
    }
}
