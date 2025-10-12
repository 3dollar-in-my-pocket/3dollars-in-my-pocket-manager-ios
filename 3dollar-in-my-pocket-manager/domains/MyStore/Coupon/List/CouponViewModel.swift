import Combine

extension CouponViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let willDisplay = PassthroughSubject<Int, Never>()
        let refresh = PassthroughSubject<Void, Never>()
        let closeCoupon = PassthroughSubject<String, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .coupon
        let datasource = PassthroughSubject<[CouponSection], Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
        let isRefreshing = CurrentValueSubject<Bool, Never>(false)
        let toast = PassthroughSubject<String, Never>()
        let showLoading = PassthroughSubject<Bool, Never>()
        let closeCouponCompleted = PassthroughSubject<Void, Never>()
    }
    
    struct State {
        var coupons: [StoreCouponResponse] = []
        var cursor: String?
        var hasMore: Bool = true
    }
    
    enum Route {
        case showCloseAlert(couponId: String)
    }
    
    struct Dependency {
        let couponRepository: CouponRepository
        let logManager: LogManagerProtocol
        let preference: Preference
        
        init(
            couponRepository: CouponRepository = CouponRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared,
            preference: Preference = Preference.shared
        ) {
            self.couponRepository = couponRepository
            self.logManager = logManager
            self.preference = preference
        }
    }
}

final class CouponViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private let statuses: [StoreCouponStatus]
    private var state = State()
    private let dependency: Dependency
    private var task: Task<Void, Never>?
    
    init(statuses: [StoreCouponStatus], dependency: Dependency = Dependency()) {
        self.statuses = statuses
        self.dependency = dependency
        
        super.init()
        
        bind()
    }
    
    private func bind() {
        Publishers.Merge(input.firstLoad, input.refresh)
            .withUnretained(self)
            .sink { (owner: CouponViewModel, _) in
                owner.state.coupons.removeAll()
                owner.state.cursor = nil
                owner.state.hasMore = true
                owner.firstLoadDatas()
            }
            .store(in: &cancellables)
        
        input.willDisplay
            .withUnretained(self)
            .sink { (owner: CouponViewModel, index: Int) in
                guard owner.canLoadMore(index: index) else { return }
                
                owner.loadMoreCoupons()
            }
            .store(in: &cancellables)
        
        input.closeCoupon
            .withUnretained(self)
            .sink { (owner: CouponViewModel, couponId: String) in
                owner.closeCoupon(couponId: couponId)
            }
            .store(in: &cancellables)
    }
    
    private func firstLoadDatas() {
        Task {
            let couponResult = await dependency.couponRepository.fetchCoupons(storeId: dependency.preference.storeId, statuses: statuses, cursor: nil)
            
            switch couponResult {
            case .success(let response):
                state.cursor = response.cursor.nextCursor
                state.hasMore = response.cursor.hasMore
                state.coupons = response.contents
            case .failure(let error):
                output.showErrorAlert.send(error)
                output.isRefreshing.send(false)
                return
            }
            
            updateDataSource()
            output.isRefreshing.send(false)
        }
    }
    
    private func loadMoreCoupons() {
        task?.cancel()
        task = Task {
            let couponResult = await dependency.couponRepository.fetchCoupons(storeId: dependency.preference.storeId, statuses: statuses, cursor: state.cursor)
            
            switch couponResult {
            case .success(let response):
                state.cursor = response.cursor.nextCursor
                state.hasMore = response.cursor.hasMore
                state.coupons.append(contentsOf: response.contents)
                updateDataSource()
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
    
    private func updateDataSource() {
        if state.coupons.isEmpty {
            output.datasource.send([.init(type: .empty, items: [.empty])])
        } else {
            let sectionItems = state.coupons.map {
                CouponSectionItem.coupon(bindCouponItemCellViewModel(with: $0))
            }
            output.datasource.send([.init(type: .coupon, items: sectionItems)])
        }
    }
    
    private func canLoadMore(index: Int) -> Bool {
        return state.hasMore && state.cursor.isNotNil && (index >= state.coupons.count - 1)
    }
    
    private func bindCouponItemCellViewModel(with model: StoreCouponResponse) -> CouponItemCellViewModel {
        let viewModel = CouponItemCellViewModel(coupon: model)
        viewModel.output.showCloseAlert
            .map { couponId in
                return .showCloseAlert(couponId: couponId)
            }
            .subscribe(output.route)
            .store(in: &viewModel.cancellables)
        return viewModel
    }
    
    private func closeCoupon(couponId: String) {
        output.showLoading.send(true)
        
        Task {
            let couponResult = await dependency.couponRepository.closeCoupon(
                storeId: dependency.preference.storeId,
                couponId: couponId
            )
            
            switch couponResult {
            case .success:
                input.refresh.send()
                output.showLoading.send(false)
                output.toast.send("쿠폰 발급을 중지했어요.")
                output.closeCouponCompleted.send()
            case .failure(let error):
                output.showLoading.send(false)
                output.showErrorAlert.send(error)
            }
        }
    }
}
