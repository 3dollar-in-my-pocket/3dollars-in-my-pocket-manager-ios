import Combine

extension StatisticsBookmarkCountCellViewModel {
    struct Input {
        let didTapSendMessage = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let bookmarkCount: Int
        let didTapSendMessage = PassthroughSubject<Void, Never>()
    }
    
    struct Config {
        let bookmarkCount: Int
    }
}

final class StatisticsBookmarkCountCellViewModel: BaseViewModel, Identifiable {
    lazy var id = ObjectIdentifier(self)
    let input = Input()
    let output: Output
    
    init(config: Config) {
        self.output = Output(bookmarkCount: config.bookmarkCount)
        
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.didTapSendMessage
            .subscribe(output.didTapSendMessage)
            .store(in: &cancellables)
    }
}

extension StatisticsBookmarkCountCellViewModel: Hashable {
    static func == (lhs: StatisticsBookmarkCountCellViewModel, rhs: StatisticsBookmarkCountCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
