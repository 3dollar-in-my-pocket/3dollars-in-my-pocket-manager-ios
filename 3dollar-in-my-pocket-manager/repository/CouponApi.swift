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
    case fetchCoupons(storeId: String, statuses: [StoreCouponStatus], cursor: String?)
    case closeCoupon(storeId: String, couponId: String)
}

extension CouponApi: ApiRequest {
    var path: String {
        switch self {
        case .registerCoupon(let input):
            return "/v1/store/\(input.storeId)/coupon"
        case .fetchCoupons(let storeId, _, _):
            return "/v1/store/\(storeId)/coupons"
        case .closeCoupon(let storeId, let couponId):
            return "/v1/store/\(storeId)/coupon/\(couponId)/close"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .registerCoupon:
            return .post
        case .fetchCoupons:
            return .get
        case .closeCoupon:
            return .put
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .registerCoupon(let input):
            return input.toDictionary
        case .fetchCoupons(_, let statuses, let cursor):
            var params: Parameters = ["size": 20]
            if let cursor {
                params["cursor"] = cursor
            }
            params["statuses"] = statuses.map { $0.rawValue }
            return params
        case .closeCoupon:
            return nil
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .registerCoupon(let input):
            var header = HTTPUtils.defaultHeader()
            header.add(HTTPHeader(name: "X-Nonce-Token", value: input.nonceToken))
            return header
        default:
            return HTTPUtils.defaultHeader()
        }
    }
}
