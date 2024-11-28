import Combine

extension MainViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let showMessageTooltip = PassthroughSubject<Void, Never>()
    }
    
    struct Dependency {
        var preference: Preference
        
        init(preference: Preference = .shared) {
            self.preference = preference
        }
    }
}

final class MainViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var dependency: Dependency
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.firstLoad
            .withUnretained(self)
            .sink { (owner: MainViewModel, _) in
                owner.showMessageTooltipIfNeeded()
            }
            .store(in: &cancellables)
    }
    
    private func showMessageTooltipIfNeeded() {
        guard dependency.preference.shownMessageTooltip.isNot else { return }
        
        dependency.preference.shownMessageTooltip = true
        output.showMessageTooltip.send(())
    }
}
