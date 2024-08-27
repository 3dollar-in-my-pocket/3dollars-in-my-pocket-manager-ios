import Combine

extension PreferenceViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let toggleRetainLocationOnClose = PassthroughSubject<Void, Never>()
        let toggleAutoOpenControl = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let retainLocationOnClose = CurrentValueSubject<Bool, Never>(false)
        let autoOpenControl = CurrentValueSubject<Bool, Never>(false)
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case showErrorAlert(Error)
    }
    
    struct Dependency {
        let preferenceRepository: PreferenceRepository
        let preference: Preference
        
        init(
            preferenceRepository: PreferenceRepository = PreferenceRepositoryImpl(),
            preference: Preference = Preference.shared
        ) {
            self.preferenceRepository = preferenceRepository
            self.preference = preference
        }
    }
}

final class PreferenceViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    
    private let dependency: Dependency
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.firstLoad
            .withUnretained(self)
            .sink { (owner: PreferenceViewModel, _) in
                owner.fetchPreference()
            }.store(in: &cancellables)
        
        input.toggleAutoOpenControl
            .withUnretained(self)
            .sink { (owner: PreferenceViewModel, _) in
                let autoOpenControl = !owner.output.autoOpenControl.value
                owner.output.autoOpenControl.send(autoOpenControl)
                owner.updatePreference()
            }
            .store(in: &cancellables)
        
        input.toggleRetainLocationOnClose
            .withUnretained(self)
            .sink { (owner: PreferenceViewModel, _) in
                let retainLocationOnClose = !owner.output.retainLocationOnClose.value
                owner.output.retainLocationOnClose.send(retainLocationOnClose)
                owner.updatePreference()
            }
            .store(in: &cancellables)
    }
    
    private func fetchPreference() {
        Task { [weak self] in
            guard let self else { return }
            
            let storeId = dependency.preference.storeId
            let result = await dependency.preferenceRepository.fetchPreference(storeId: storeId)
            
            switch result {
            case .success(let response):
                output.autoOpenControl.send(response.autoOpenCloseControl)
                output.retainLocationOnClose.send(response.retainLocationOnClose)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func updatePreference() {
        Task { [weak self] in
            guard let self else { return }
            
            let storeId = dependency.preference.storeId
            let request = StorePreferencePatchRequest(
                retainLocationOnClose: output.retainLocationOnClose.value,
                autoOpenCloseControl: output.autoOpenControl.value
            )
            let result = await dependency.preferenceRepository.updatePreference(
                storeId: storeId,
                storePreferencePatchRequest: request
            )
            
            switch result {
            case .success(_):
                break
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
}
