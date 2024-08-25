import Foundation

struct StorePreferencePatchRequest: Encodable {
    let retainLocationOnClose: Bool
    let autoOpenCloseControl: Bool
}

struct StorePreferenceResponse: Decodable {
    let retainLocationOnClose: Bool
    let autoOpenCloseControl: Bool
}
