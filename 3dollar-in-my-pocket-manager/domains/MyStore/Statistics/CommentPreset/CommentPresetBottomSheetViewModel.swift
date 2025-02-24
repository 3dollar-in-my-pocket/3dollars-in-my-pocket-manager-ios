import Combine

extension CommentPresetBottomSheetViewModel {
    struct Input {
        let didTapPreset = PassthroughSubject<Int, Never>()
        let didTapAddPreset = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let dataSource: [CommentPresetCellViewModel]
        let didTapPreset = PassthroughSubject<CommentPresetResponse, Never>()
        let didTapAddPreset = PassthroughSubject<Void, Never>()
    }
    
    struct Relay {
        let didTapEditPreset = PassthroughSubject<CommentPresetResponse, Never>()
        let didTapDeletePreset = PassthroughSubject<CommentPresetResponse, Never>()
    }
    
    struct State {
        var presets: [CommentPresetResponse] = []
    }
    
    struct Config {
        var presets: [CommentPresetResponse] = []
    }
}

final class CommentPresetBottomSheetViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    let relay = Relay()
    private var state: State
    
    
    init(config: Config) {
        let cellViewModels = config.presets.map { preset in
            let config = CommentPresetCellViewModel.Config(preset: preset)
            let viewModel = CommentPresetCellViewModel(config: config)
            return viewModel
        }
        
        self.output = Output(dataSource: cellViewModels)
        self.state = State(presets: config.presets)
        
        super.init()
        
        bind()
        bindCellViewModels()
    }
    
    private func bind() {
        input.didTapPreset
            .withUnretained(self)
            .sink { (owner: CommentPresetBottomSheetViewModel, index: Int) in
                guard let preset = owner.state.presets[safe: index] else { return }
                
                owner.output.didTapPreset.send(preset)
            }
            .store(in: &cancellables)
        
        input.didTapAddPreset
            .subscribe(output.didTapAddPreset)
            .store(in: &cancellables)
    }
    
    private func bindCellViewModels() {
        for cellViewModel in output.dataSource {
            cellViewModel.output.didTapEdit
                .subscribe(relay.didTapEditPreset)
                .store(in: &cellViewModel.cancellables)
            
            cellViewModel.output.didTapDelete
                .subscribe(relay.didTapDeletePreset)
                .store(in: &cellViewModel.cancellables)
        }
    }
}
