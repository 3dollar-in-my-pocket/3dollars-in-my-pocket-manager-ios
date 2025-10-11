import Foundation
import Alamofire

protocol CouponRepository {
    func registerCoupon(input: RegisterCouponInput) async -> ApiResult<StoreCouponResponse>
}


final class CouponRepositoryImpl: CouponRepository {
    func registerCoupon(input: RegisterCouponInput) async -> ApiResult<StoreCouponResponse> {
        return await CouponApi.registerCoupon(input).asyncRequest()
    }
}
