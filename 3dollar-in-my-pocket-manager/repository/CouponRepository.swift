import Foundation
import Alamofire

protocol CouponRepository {
    func registerCoupon(input: RegisterCouponInput) async -> ApiResult<StoreCouponResponse>
    
    func fetchCoupons(storeId: String, statuses: [StoreCouponStatus], cursor: String?) async -> ApiResult<ContentListWithCursor<StoreCouponResponse>>
    
    func closeCoupon(storeId: String, couponId: String) async -> ApiResult<String>
}


final class CouponRepositoryImpl: CouponRepository {
    func registerCoupon(input: RegisterCouponInput) async -> ApiResult<StoreCouponResponse> {
        return await CouponApi.registerCoupon(input).asyncRequest()
    }
    
    func fetchCoupons(storeId: String, statuses: [StoreCouponStatus], cursor: String?) async -> ApiResult<ContentListWithCursor<StoreCouponResponse>> {
        return await CouponApi.fetchCoupons(storeId: storeId, statuses: statuses, cursor: cursor).asyncRequest()
    }
    
    func closeCoupon(storeId: String, couponId: String) async -> ApiResult<String> {
        return await CouponApi.closeCoupon(storeId: storeId, couponId: couponId).asyncRequest()
    }
}
