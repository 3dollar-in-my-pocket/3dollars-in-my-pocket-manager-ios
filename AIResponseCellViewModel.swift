import Combine

extension AIResponseCellViewModel {
    struct Input {
        let onError = PassthroughSubject<Error, Never>()
    }
    
    struct Output {
        let markdown: String
        let onError = PassthroughSubject<Error, Never>()
    }
    
    struct Config {
        let markdown: String
    }
}

final class AIResponseCellViewModel: BaseViewModel, Identifiable {
    let input = Input()
    let output: Output
    lazy var id = ObjectIdentifier(self)
    
    init(config: Config) {
        self.output = Output(markdown: config.markdown)
        super.init()
        bind()
    }
    
    private func bind() {
        input.onError
            .subscribe(output.onError)
            .store(in: &cancellables)
    }
}

extension AIResponseCellViewModel: Hashable {
    static func == (lhs: AIResponseCellViewModel, rhs: AIResponseCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
