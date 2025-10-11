import UIKit
import Combine

extension CouponRegisterViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let inputCouponName = PassthroughSubject<String, Never>()
        let inputStartDate =  PassthroughSubject<String, Never>()
        let inputEndDate =  PassthroughSubject<String, Never>()
        let inputCount =  PassthroughSubject<Int?, Never>()
        
        let didTapRegister = PassthroughSubject<Void, Never>()
        let request = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .registerCoupon
        let isEnableRegisterButton = CurrentValueSubject<Bool, Never>(false)
        let route = PassthroughSubject<Route, Never>()
        let toast = PassthroughSubject<String, Never>()
        let showLoading = PassthroughSubject<Bool, Never>()
    }
    
    enum Route {
        case showErrorAlert(Error)
        case pop
        case showRegisterAlertView
    }
    
    struct Dependency {
        let couponRepository: CouponRepository
        let sharedRepository: SharedRepository
        let logManager: LogManagerProtocol
        let preference: Preference
        
        init(
            couponRepository: CouponRepository = CouponRepositoryImpl(),
            sharedRepository: SharedRepository = SharedRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared,
            preference: Preference = Preference.shared
        ) {
            self.couponRepository = couponRepository
            self.sharedRepository = sharedRepository
            self.logManager = logManager
            self.preference = preference
        }
    }
    
    struct State {
        var name: String = ""
        var startDate: String = ""
        var endDate: String = ""
        var count: Int? = 999
        var nonceToken: String?
    }
}

final class CouponRegisterViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    
    private var state = State()
    private let dependency: Dependency
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        self.output = Output()
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.firstLoad
            .withUnretained(self)
            .sink { (owner: CouponRegisterViewModel, _) in
                owner.createNonceToken()
            }
            .store(in: &cancellables)
        
        input.inputCouponName
            .dropFirst()
            .withUnretained(self)
            .sink { (owner: CouponRegisterViewModel, name: String) in
                owner.state.name = name
                owner.output.isEnableRegisterButton.send(owner.validateStore())
            }
            .store(in: &cancellables)
        
        input.inputStartDate
            .withUnretained(self)
            .sink { (owner: CouponRegisterViewModel, startDate: String) in
                owner.state.startDate = startDate
                owner.output.isEnableRegisterButton.send(owner.validateStore())
            }
            .store(in: &cancellables)
        
        input.inputEndDate
            .withUnretained(self)
            .sink { (owner: CouponRegisterViewModel, endDate: String) in
                owner.state.endDate = endDate
                owner.output.isEnableRegisterButton.send(owner.validateStore())
            }
            .store(in: &cancellables)
        
        input.inputCount
            .withUnretained(self)
            .sink { (owner: CouponRegisterViewModel, count: Int?) in
                owner.state.count = count
                owner.output.isEnableRegisterButton.send(owner.validateStore())
            }
            .store(in: &cancellables)
        
        input.didTapRegister
            .withUnretained(self)
            .sink { (owner: CouponRegisterViewModel, _) in
                owner.output.route.send(.showRegisterAlertView)
            }
            .store(in: &cancellables)
        
        input.request
            .withUnretained(self)
            .sink { (owner: CouponRegisterViewModel, _) in
                owner.registerCoupon()
            }
            .store(in: &cancellables)
    }
    
    private func validateStore() -> Bool {
        return state.name.isNotEmpty
        && state.startDate.isNotEmpty
        && state.endDate.isNotEmpty
        && state.count.isNotNil
    }
    
    private func createNonceToken() {
        Task {
            let nonceResult = await dependency.sharedRepository.createNonce(input: .init())
            
            switch nonceResult {
            case .success(let response):
                state.nonceToken = response.nonce
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func registerCoupon() {
        guard let nonceToken = state.nonceToken else { return }
        
        output.showLoading.send(true)
        
        Task { [weak self] in
            guard let self else { return }
            
            let request = RegisterCouponInput(
                storeId: dependency.preference.storeId,
                name: state.name,
                description: nil,
                maxIssuableCount: state.count ?? 0,
                validityPeriod: .init(
                    startDateTime: state.startDate,
                    endDateTime: state.endDate
                ),
                nonceToken: nonceToken
            )
            let result = await dependency.couponRepository.registerCoupon(input: request)
            
            switch result {
            case .success(_):
                output.showLoading.send(false)
                output.toast.send("쿠폰이 발급되었어요.")
                output.route.send(.pop)
            case .failure(let error):
                output.showLoading.send(false)
                output.route.send(.showErrorAlert(error))
            }
        }
    }
}

// MARK: - Log
extension CouponRegisterViewModel {
    
}
