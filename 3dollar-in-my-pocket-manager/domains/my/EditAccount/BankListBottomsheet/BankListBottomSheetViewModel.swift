import Combine

extension BankListBottomSheetViewModel {
    struct Input {
        let didSelectItem = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        let bankList: CurrentValueSubject<[BossBank], Never>
        let selectedIndex: CurrentValueSubject<Int?, Never>
        let finishSelectBank = PassthroughSubject<BossBank, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct Config {
        let selectedBank: BossBank?
        let bankList: [BossBank]
    }
    
    enum Route {
        case dismiss
    }
}

final class BankListBottomSheetViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    
    init(config: Config) {
        var selectedIndex: Int? = nil
        if let selectedBank = config.selectedBank {
            selectedIndex = config.bankList.firstIndex(of: selectedBank)
        }
        
        self.output = Output(bankList: .init(config.bankList), selectedIndex: .init(selectedIndex))
        
        super.init()
        
        bind()
    }
    
    private func bind() {
        input.didSelectItem
            .withUnretained(self)
            .sink { (owner: BankListBottomSheetViewModel, index: Int) in
                owner.selectItem(index)
            }
            .store(in: &cancellables)
    }
    
    private func selectItem(_ index: Int) {
        guard let selectedBank = output.bankList.value[safe: index] else { return }
        output.finishSelectBank.send(selectedBank)
        output.route.send(.dismiss)
    }
}
