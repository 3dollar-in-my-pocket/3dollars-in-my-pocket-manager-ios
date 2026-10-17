import Foundation

/// 테스트 번들의 `Resources/{name}.json` 픽스처를 읽는다.
/// 픽스처는 실서버 응답에서 `{ok, data}` 래퍼를 벗긴 `data` 만 저장한다 (docs/process/testing.md "픽스처 규칙").
enum FixtureLoader {
    private final class BundleToken {}

    static func data(_ name: String) throws -> Data {
        let bundle = Bundle(for: BundleToken.self)
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw FixtureError.notFound(name)
        }
        return try Data(contentsOf: url)
    }

    static func decode<T: Decodable>(_ type: T.Type, from name: String) throws -> T {
        try JSONDecoder().decode(type, from: data(name))
    }

    enum FixtureError: Error {
        case notFound(String)
    }
}
