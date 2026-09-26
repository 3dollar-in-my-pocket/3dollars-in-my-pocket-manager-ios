import Foundation

@testable import _dollar_in_my_pocket_manager

/// LogManagerProtocol 스파이. 전송된 로그를 기록만 하고 실제로 보내지 않는다.
final class MockLogManager: LogManagerProtocol {
    private(set) var pageViews: [ScreenName] = []
    private(set) var sentEvents: [LogEvent] = []
    private(set) var userIds: [String] = []

    func sendPageView(screen: ScreenName, type: AnyObject.Type) {
        pageViews.append(screen)
    }

    func sendEvent(_ event: LogEvent) {
        sentEvents.append(event)
    }

    func setUserId(_ userId: String) {
        userIds.append(userId)
    }
}
