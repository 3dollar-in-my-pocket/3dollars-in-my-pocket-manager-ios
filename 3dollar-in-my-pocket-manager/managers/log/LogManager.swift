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
    
    private let osLogger = Logger(subsystem: Bundle.identifier, category: LogCategory.logManager.rawValue)
    
    func sendPageView(screen: ScreenName, type: AnyObject.Type) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screen.rawValue,
            AnalyticsParameterScreenClass: NSStringFromClass(type.self)
        ])
        
        debugPageView(screen: screen, type: type)
    }
    
    func sendEvent(_ event: LogEvent) {
        Analytics.logEvent(event.name.rawValue, parameters: event.parameters)
        
        debugCustomEvent(event)
    }
    
    func setUserId(_ userId: String) {
        Analytics.setUserID(userId)
    }
    
    private func debugPageView(screen: ScreenName, type: AnyObject.Type) {
        osLogger.debug("""
        [✍️LogManager]
        => type: PageView
        => screen: \(screen.rawValue)
        => class: \(String(describing: type))
        """)
    }
    
    private func debugCustomEvent(_ event: LogEvent) {
        osLogger.debug("""
        [✍️LogManager]
        => type: CustomEvent
        => naem: \(event.name.rawValue)
        => parameter: \(event.parameters.prettyString)
        """)
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
