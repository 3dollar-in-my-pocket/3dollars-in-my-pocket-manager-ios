enum ApiErrorType: String, Decodable {
    case unauthorized
    case serviceUnavailable
    case notExistsSignupRegistration
    case forbiddenWaitingApproveRegistration
    case unknown
    
    init(from decoder: any Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(RawValue.self).camelCase
        self = ApiErrorType(rawValue: rawValue) ?? .unknown
    }
}
