import Combine

extension CommentPresetBottomSheetViewModel {
    enum Constants {
        static let maxPresetCount = 5
    }
    
    struct Input {
        let didTapPreset = PassthroughSubject<Int, Never>()
        let didTapAddPreset = PassthroughSubject<Void, Never>()
        let deleteCommentPreset = PassthroughSubject<CommentPresetResponse, Never>()
    }
    
    struct Output {
        var dataSource: [CommentPresetCellViewModel]
        let reload = PassthroughSubject<Void, Never>()
        let didTapPreset = PassthroughSubject<CommentPresetResponse, Never>()
        let didTapAddPreset = PassthroughSubject<Void, Never>()
        let enableAddPresetButton: CurrentValueSubject<Bool, Never>
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct Relay {
        let didTapEditPreset = PassthroughSubject<CommentPresetResponse, Never>()
        let didTapDeletePreset = PassthroughSubject<CommentPresetResponse, Never>()
    }
    
    struct State {
        var presets: [CommentPresetResponse] = []
    }
    
    enum Route {
        case presetDeleteAlert(CommentPresetResponse)
        case showErrorAlert(Error)
        case dismiss
    }
    
    struct Config {
        var presets: [CommentPresetResponse] = []
    }
    
    struct Dependency {
        let reviewRepository: ReviewRepository
        let preference: Preference
        
        init(
            reviewRepository: ReviewRepository = ReviewRepositoryImpl(),
            preference: Preference = .shared
        ) {
            self.reviewRepository = reviewRepository
            self.preference = preference
        }
    }
}

final class CommentPresetBottomSheetViewModel: BaseViewModel {
    let input = Input()
    var output: Output
    let relay = Relay()
    private var state: State
    private let dependency: Dependency
    
    
    init(config: Config, dependency: Dependency = Dependency()) {
        let cellViewModels = config.presets.map { preset in
            let config = CommentPresetCellViewModel.Config(preset: preset)
            let viewModel = CommentPresetCellViewModel(config: config)
            return viewModel
        }
        
        self.output = Output(
            dataSource: cellViewModels,
            enableAddPresetButton: .init(config.presets.count < Constants.maxPresetCount)
        )
        self.dependency = dependency
        self.state = State(presets: config.presets)
        
        super.init()
        
        bind()
        bindCellViewModels()
        bindRelay()
    }
    
    private func bind() {
        input.didTapPreset
            .withUnretained(self)
            .sink { (owner: CommentPresetBottomSheetViewModel, index: Int) in
                guard let preset = owner.state.presets[safe: index] else { return }
                
                owner.output.didTapPreset.send(preset)
                owner.output.route.send(.dismiss)
            }
            .store(in: &cancellables)
        
        input.didTapAddPreset
            .subscribe(output.didTapAddPreset)
            .store(in: &cancellables)
        
        input.deleteCommentPreset
            .withUnretained(self)
            .sink { (owner: CommentPresetBottomSheetViewModel, commentPreset: CommentPresetResponse) in
                owner.deleteCommentPreset(commentPreset: commentPreset)
            }
            .store(in: &cancellables)
    }
    
    private func bindRelay() {
        relay.didTapDeletePreset
            .withUnretained(self)
            .sink { (owner: CommentPresetBottomSheetViewModel, commentPreset: CommentPresetResponse) in
                owner.output.route.send(.presetDeleteAlert(commentPreset))
            }
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
    
    private func deleteCommentPreset(commentPreset: CommentPresetResponse) {
        Task {
            let storeId = dependency.preference.storeId
            let result = await dependency.reviewRepository.deleteCommentPreset(storeId: storeId, commentPresetId: commentPreset.presetId)
            
            switch result {
            case .success:
                if let targetIndex = output.dataSource.firstIndex(where: { $0.output.preset == commentPreset }) {
                    output.dataSource.remove(at: targetIndex)
                }
                output.reload.send(())
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
}
