import Foundation
import Combine

extension SplashViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let finishAnimation = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case goToSignIn
        case goToMain
        case goToWaiting
    }
    
    struct Dependency {
        let userRepository: UserRepository
        let preference: Preference
        
        init(userRepository: UserRepository = UserRepositoryImpl(), preference: Preference = .shared) {
            self.userRepository = userRepository
            self.preference = preference
        }
    }
}

final class SplashViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private let dependency: Dependency
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.load
            .filter { [weak self] in
                guard let self else { return false}
                return dependency.preference.userToken.isEmpty
            }
            .combineLatest(input.finishAnimation)
            .sink { [weak self] _ in
                guard let self else { return }
                output.route.send(.goToSignIn)
            }
            .store(in: &cancellables)
        
        input.load
            .filter { [weak self] in
                guard let self else { return false}
                return dependency.preference.userToken.isNotEmpty
            }
            .sink { [weak self] in
                self?.validateUser()
            }
            .store(in: &cancellables)
    }
    
    private func validateUser() {
        let userResultPublisher = Future<ApiResult<BossWithSettingsResponse>, Never> { promise in
            Task {
                let userResult = await self.dependency.userRepository.fetchUser()
                promise(.success(userResult))
            }
        }
        
        Publishers.CombineLatest(userResultPublisher, input.finishAnimation)
            .sink { [weak self] (userResult, _) in
                guard let self = self else { return }
                
                switch userResult {
                case .success(_):
                    output.route.send(.goToMain)
                case .failure(let error):
                    if let httpError = error as? HTTPError {
                        switch httpError {
                        case .unauthorized:
                            output.route.send(.goToSignIn)
                        case .forbidden:
                            output.route.send(.goToWaiting)
                        case .notFound:
                            output.route.send(.goToSignIn)
                        default:
                            output.showErrorAlert.send(error)
                        }
                    } else {
                        output.showErrorAlert.send(error)
                    }
                }
            }
            .store(in: &cancellables)
    }
}
