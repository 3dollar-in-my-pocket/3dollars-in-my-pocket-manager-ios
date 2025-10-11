import Alamofire

struct RegisterCouponInput: Encodable {
    let storeId: String
    let name: String
    let description: String?
    let maxIssuableCount: Int
    let validityPeriod: RegisterCouponDateInput
    let nonceToken: String
    
    struct RegisterCouponDateInput: Encodable {
        let startDateTime: String
        let endDateTime: String
    }
}

enum CouponApi {
    case registerCoupon(RegisterCouponInput)
}

extension CouponApi: ApiRequest {
    var path: String {
        switch self {
        case .registerCoupon(let input):
            return "/v1/store/\(input.storeId)/coupon"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .registerCoupon:
            return .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .registerCoupon(let input):
            return input.toDictionary
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .registerCoupon(let input):
            var header = HTTPUtils.defaultHeader()
            header.add(HTTPHeader(name: "X-Nonce-Token", value: input.nonceToken))
            return header
        }
    }
}
