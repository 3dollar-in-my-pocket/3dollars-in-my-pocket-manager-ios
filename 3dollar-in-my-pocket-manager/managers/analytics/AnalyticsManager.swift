import Foundation

protocol AnalyticsManagerProtocol {
    func sendEvent(event: AnalyticsEvent)
}

final class AnalyticsManager: AnalyticsManagerProtocol {
    static let shared = AnalyticsManager()
    
    private let managers: [AnalyticsManagerProtocol] = [GAManager.shared]
    
    func sendEvent(event: AnalyticsEvent) {
        for manager in self.managers {
            manager.sendEvent(event: event)
        }
    }
}
