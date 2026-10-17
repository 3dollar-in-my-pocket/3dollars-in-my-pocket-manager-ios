import XCTest

@testable import _dollar_in_my_pocket_manager

final class ApiErrorContainerTests: XCTestCase {

    // MARK: TH-1384 TC5

    func test_TH1384_TC5_아는에러코드는_스네이크케이스에서_해당case로디코딩된다() throws {
        // Given
        let name = "ApiErrorContainerServiceUnavailable"

        // When
        let container = try FixtureLoader.decode(ApiErrorContainer.self, from: name)

        // Then
        XCTAssertEqual(container.error, .serviceUnavailable)
        XCTAssertEqual(container.message, "서버 점검 중입니다")
    }

    func test_TH1384_TC5_모르는에러코드가와도_크래시없이unknown으로디코딩된다() throws {
        // Given
        let name = "ApiErrorContainerUnknownError"

        // When
        let container = try FixtureLoader.decode(ApiErrorContainer.self, from: name)

        // Then
        XCTAssertEqual(container.error, .unknown)
    }
}
