import Combine

extension AIErrorCellViewModel {
    struct Input {
        let didTapRetry = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let error: Error
        let didTapRetry = PassthroughSubject<Void, Never>()
    }
    
    struct Config {
        let error: Error
    }
}

final class AIErrorCellViewModel: BaseViewModel, Identifiable {
    let input = Input()
    let output: Output
    lazy var id = ObjectIdentifier(self)
    
    init(config: Config) {
        self.output = Output(error: config.error)
        super.init()
        bind()
    }
    
    private func bind() {
        input.didTapRetry
            .subscribe(output.didTapRetry)
            .store(in: &cancellables)
    }
}

extension AIErrorCellViewModel: Hashable {
    static func == (lhs: AIErrorCellViewModel, rhs: AIErrorCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
