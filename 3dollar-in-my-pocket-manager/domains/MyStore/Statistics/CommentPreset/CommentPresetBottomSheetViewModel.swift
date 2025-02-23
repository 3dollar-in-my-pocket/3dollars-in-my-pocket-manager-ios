import Combine

extension CommentPresetBottomSheetViewModel {
    struct Input {
        let didTapPreset = PassthroughSubject<Int, Never>()
        let didTapAddPreset = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var dataSource: [CommentPresetCellViewModel]
        let didTapPreset = PassthroughSubject<CommentPresetResponse, Never>()
        let didTapAddPreset = PassthroughSubject<Void, Never>()
    }
    
    struct Relay {
        let didTapEditPreset = PassthroughSubject<CommentPresetResponse, Never>()
        let didTapDeletePreset = PassthroughSubject<CommentPresetResponse, Never>()
    }
    
    struct Config {
        var presets: [CommentPresetResponse] = []
    }
}

final class CommentPresetBottomSheetViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    let relay = Relay()
    
    
    init(config: Config) {
        let cellViewModels = config.presets.map { preset -> CommentPresetCellViewModel in
            let config = CommentPresetCellViewModel.Config(preset: preset)
            let viewModel = CommentPresetCellViewModel(config: config)
            return viewModel
        }
        
        self.output = Output(dataSource: cellViewModels)
        super.init()
        
        bind()
        bindCellViewModels()
    }
    
    private func bind() {
        input.didTapPreset
            .withUnretained(self)
            .sink { (owner: CommentPresetBottomSheetViewModel, index: Int) in
                guard let preset = owner.output.dataSource[safe: index]?.output.preset else { return }
                
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
