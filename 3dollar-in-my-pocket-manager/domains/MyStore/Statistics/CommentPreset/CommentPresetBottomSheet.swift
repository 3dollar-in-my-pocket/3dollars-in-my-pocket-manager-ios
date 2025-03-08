import UIKit

import PanModal

final class CommentPresetBottomSheet: BaseViewController {
    enum Layout {
        static let itemSpace: CGFloat = 24
        static let minimumCollectionViewHeight: CGFloat = 160
        static let maximumCollectionViewHeight: CGFloat = 336
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .semiBold(size: 20)
        label.textColor = .gray100
        label.text = Strings.CommentPresetBottomSheet.title
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Assets.icDeleteX.image, for: .normal)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.register([
            BaseCollectionViewCell.self,
            CommentPresetCell.self,
            CommentPresetEmptyCell.self
        ])
        collectionView.delegate = self
        return collectionView
    }()
    
    private let addPresetButton: UIButton = {
        let button = UIButton()
        button.setTitle(Strings.CommentPresetBottomSheet.addPreset, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .semiBold(size: 14)
        button.backgroundColor = .green
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    private let viewModel: CommentPresetBottomSheetViewModel
    
    init(viewModel: CommentPresetBottomSheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        setupUI()
        setupAttributes()
        bind()
        
        updateCollectionViewHeight()
    }
    
    private func setupAttributes() {
        view.backgroundColor = .white
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(collectionView)
        view.addSubview(addPresetButton)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.trailing.lessThanOrEqualTo(closeButton.snp.leading).offset(-16)
        }
        
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.size.equalTo(30)
            $0.centerY.equalTo(titleLabel)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(26)
            $0.height.equalTo(160)
        }
        
        addPresetButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(collectionView.snp.bottom).offset(28)
            $0.height.equalTo(48)
        }
    }
    
    private func bind() {
        // Input
        addPresetButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapAddPreset)
            .store(in: &cancellables)
        
        closeButton.tapPublisher
            .main
            .throttleClick()
            .withUnretained(self)
            .sink { (owner: CommentPresetBottomSheet, _) in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
        
        // Output
        viewModel.output.reload
            .main
            .withUnretained(self)
            .sink { (owner: CommentPresetBottomSheet, _) in
                owner.updateCollectionViewHeight()
                owner.collectionView.reloadData()
                owner.panModalSetNeedsLayoutUpdate()
            }
            .store(in: &cancellables)
        
        viewModel.output.enableAddPresetButton
            .main
            .withUnretained(self)
            .sink { (owner: CommentPresetBottomSheet, isEnable: Bool) in
                owner.addPresetButton.isEnabled = isEnable
                let backGroundColor = isEnable ? UIColor.green : UIColor.gray30
                owner.addPresetButton.backgroundColor = backGroundColor
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: CommentPresetBottomSheet, route: CommentPresetBottomSheetViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Layout.itemSpace
        layout.minimumInteritemSpacing = Layout.itemSpace
        return layout
    }
    
    private func getHeight() -> CGFloat {
        let cellHeights = viewModel.output.dataSource.map {
            return CommentPresetCell.Layout.calculateHeight(preset: $0.output.preset)
        }
        
        let space = CGFloat(cellHeights.count - 1) * Layout.itemSpace
        let collectionViewHeight = cellHeights.reduce(0, +) + space
        
        return 178 + min(max(collectionViewHeight, Layout.minimumCollectionViewHeight), Layout.maximumCollectionViewHeight)
    }
    
    private func updateCollectionViewHeight() {
        let cellHeights = viewModel.output.dataSource.map {
            return CommentPresetCell.Layout.calculateHeight(preset: $0.output.preset)
        }
        
        let space = CGFloat(cellHeights.count - 1) * Layout.itemSpace
        let collectionViewHeight = cellHeights.reduce(0, +) + space
        
        collectionView.snp.updateConstraints {
            $0.height.equalTo(min(max(collectionViewHeight, Layout.minimumCollectionViewHeight), Layout.maximumCollectionViewHeight))
        }
    }
}

// MARK: Route
extension CommentPresetBottomSheet {
    private func handleRoute(_ route: CommentPresetBottomSheetViewModel.Route) {
        switch route {
        case .dismiss:
            dismiss(animated: true)
        case .presetDeleteAlert(let commentPreset):
            AlertUtils.showWithCancel(viewController: self, message: Strings.CommentPresetBottomSheet.deleteAlert) { [weak self] in
                self?.viewModel.input.deleteCommentPreset.send(commentPreset)
            }
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
}

extension CommentPresetBottomSheet: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(viewModel.output.dataSource.count, 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.output.dataSource.isEmpty {
            let cell: CommentPresetEmptyCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            return cell
        } else {
            guard let cellViewModel = viewModel.output.dataSource[safe: indexPath.item] else {
                return BaseCollectionViewCell()
            }
            let cell: CommentPresetCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(viewModel: cellViewModel)
            return cell
        }
    }
}

extension CommentPresetBottomSheet: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if viewModel.output.dataSource.isEmpty {
            return CGSize(width: UIUtils.windowBounds.width, height: CommentPresetEmptyCell.Layout.height)
        } else {
            guard let cellViewModel = viewModel.output.dataSource[safe: indexPath.item] else { return .zero }
            let height = CommentPresetCell.Layout.calculateHeight(preset: cellViewModel.output.preset)
            return CGSize(width: UIUtils.windowBounds.width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.didTapPreset.send(indexPath.item)
    }
}

extension CommentPresetBottomSheet: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(getHeight())
    }
    
    var longFormHeight: PanModalHeight {
        return shortFormHeight
    }
    
    var cornerRadius: CGFloat {
        return 16
    }
    
    var showDragIndicator: Bool {
        return false
    }
}
