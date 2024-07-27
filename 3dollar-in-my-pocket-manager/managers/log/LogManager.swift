import Foundation
import OSLog

import FirebaseAnalytics

protocol LogManagerProtocol {
    func sendPageView(screen: ScreenName, type: AnyObject.Type)
    
    func sendEvent(_ event: LogEvent)
    
    func setUserId(_ userId: String)
}

final class LogManager: LogManagerProtocol {
    static let shared = LogManager()
    private var isEnableDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    func sendPageView(screen: ScreenName, type: AnyObject.Type) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screen.rawValue,
            AnalyticsParameterScreenClass: NSStringFromClass(type.self)
        ])
        
        if isEnableDebug {
            debugPageView(screen: screen, type: type)
        }
    }
    
    func sendEvent(_ event: LogEvent) {
        Analytics.logEvent(event.name.rawValue, parameters: event.parameters)
        
        if isEnableDebug {
            debugCustomEvent(event)
        }
    }
    
    func setUserId(_ userId: String) {
        Analytics.setUserID(userId)
    }
    
    private func debugPageView(screen: ScreenName, type: AnyObject.Type) {
        let message: StaticString = """
        🧡 [LogManager]: PageView
            => screen: %{PUBLIC}@
            => type: %{PUBLIC}@
        """
        
        os_log(.debug, message, screen.rawValue, String(describing: type))
    }
    
    private func debugCustomEvent(_ event: LogEvent) {
        let message: StaticString = """
        🧡 [LogManager]: CustomEvent
            => name: %{PUBLIC}@
            => parameter: %{PUBLIC}@
        """
        
        os_log(.debug, message, event.name.rawValue, event.parameters.prettyString)
    }
}

fileprivate extension Dictionary where Key == String {
    var prettyString: String {
        var result = ""
        for pair in self {
            result += "\n\t\(pair.key): \(pair.value),"
        }

        return result
    }
}
