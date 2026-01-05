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
        case showUpdateAlert(title: String, message: String, url: URL?)
        case showErrorAlert(Error)
    }

    struct Dependency {
        let userRepository: UserRepository
        let appRepository: AppRepository
        let preference: Preference

        init(
            userRepository: UserRepository = UserRepositoryImpl(),
            appRepository: AppRepository = AppRepositoryImpl(),
            preference: Preference = .shared
        ) {
            self.userRepository = userRepository
            self.appRepository = appRepository
            self.preference = preference
        }
    }

    enum AppStatusResult {
        case forceUpdate(title: String, message: String, url: URL?)
        case proceed
        case error(Error)
    }
}

final class SplashViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private let dependency: Dependency
    private let defaultAppStoreUrl = "itms-apps://itunes.apple.com/app/id1639708958"

    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        super.init()

        bind()
    }

    private func bind() {
        let appStatusPublisher = input.load
            .flatMap { [weak self] _ -> AnyPublisher<AppStatusResult, Never> in
                guard let self else {
                    return Just(AppStatusResult.proceed).eraseToAnyPublisher()
                }
                return self.fetchAppStatus()
            }

        Publishers.Zip(appStatusPublisher, input.finishAnimation)
            .sink { [weak self] (appStatusResult, _) in
                self?.handleAppStatusResult(appStatusResult)
            }
            .store(in: &cancellables)
    }

    private func fetchAppStatus() -> AnyPublisher<AppStatusResult, Never> {
        return Future<AppStatusResult, Never> { [weak self] promise in
            guard let self else {
                promise(.success(.proceed))
                return
            }

            Task {
                let result = await self.dependency.appRepository.fetchAppStatus()

                switch result {
                case .success(let appStatus):
                    if appStatus.forceUpdate.enabled {
                        let title = appStatus.forceUpdate.title ?? Strings.Splash.ForceUpdate.title
                        let message = appStatus.forceUpdate.message ?? Strings.Splash.ForceUpdate.message
                        let url = URL(string: appStatus.forceUpdate.linkUrl ?? self.defaultAppStoreUrl)
                        promise(.success(.forceUpdate(title: title, message: message, url: url)))
                    } else {
                        promise(.success(.proceed))
                    }
                case .failure(let error):
                    promise(.success(.error(error)))
                }
            }
        }.eraseToAnyPublisher()
    }

    private func handleAppStatusResult(_ result: AppStatusResult) {
        switch result {
        case .forceUpdate(let title, let message, let url):
            output.route.send(.showUpdateAlert(title: title, message: message, url: url))

        case .proceed:
            if dependency.preference.userToken.isEmpty {
                output.route.send(.goToSignIn)
            } else {
                validateUser()
            }

        case .error(let error):
            output.route.send(.showErrorAlert(error))
        }
    }

    private func validateUser() {
        Task { [weak self] in
            guard let self else { return }

            let userResult = await dependency.userRepository.fetchUser()

            await MainActor.run {
                switch userResult {
                case .success(let response):
                    self.dependency.preference.enableAIRecommendation = response.settings.enableSalesAIRecommendation
                    self.output.route.send(.goToMain)
                case .failure(let error):
                    self.output.showErrorAlert.send(error)
                }
            }
        }
    }
}
