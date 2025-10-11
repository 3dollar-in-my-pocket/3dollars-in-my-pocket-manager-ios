import Foundation
import Combine

extension CouponItemCellViewModel {
    struct Input {
        let didTapClose = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var coupon: StoreCouponResponse
        let showCloseAlert = PassthroughSubject<String, Never>()
    }
}

final class CouponItemCellViewModel: BaseViewModel, Identifiable {
    let input = Input()
    var output: Output
    lazy var id = ObjectIdentifier(self)
    
    init(coupon: StoreCouponResponse) {
        self.output = Output(coupon: coupon)
        
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.didTapClose
            .withUnretained(self)
            .map { (owner: CouponItemCellViewModel, _) in
                owner.output.coupon.couponId
            }
            .subscribe(output.showCloseAlert)
            .store(in: &cancellables)
    }
}

extension CouponItemCellViewModel: Hashable {
    static func == (lhs: CouponItemCellViewModel, rhs: CouponItemCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
