import Foundation

struct StorePreferencePatchRequest: Encodable {
    let removeLocationOnClose: Bool
    let autoOpenCloseControl: Bool
}

struct StorePreferenceResponse: Decodable {
    let removeLocationOnClose: Bool
    let autoOpenCloseControl: Bool
}
