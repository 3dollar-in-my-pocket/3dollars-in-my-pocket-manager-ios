import XCTest

extension XCTestCase {
    /// 조건이 참이 될 때까지 메인 액터에서 짧게 폴링한다.
    /// `@Observable` ViewModel 의 `state` 는 Subject 가 없어 expectation 을 걸 수 없으므로, 비동기 Input 뒤 state 변화를 이걸로 기다린다.
    @MainActor
    func waitUntil(
        timeout: TimeInterval = 1,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ condition: () -> Bool
    ) async throws {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() {
            guard Date() < deadline else {
                XCTFail("waitUntil: \(timeout)초 안에 조건이 참이 되지 않았다", file: file, line: line)
                return
            }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
    }
}
