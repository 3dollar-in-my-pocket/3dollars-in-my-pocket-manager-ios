import UIKit

final class CommentPresetBottomSheet: BaseViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .semiBold(size: 20)
        label.textColor = .gray100
        label.text = "자주 쓰는 문구"
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
            CommentPresetCell.self
        ])
        return collectionView
    }()
    
    private let addPresetButton: UIButton = {
        let button = UIButton()
        button.setTitle("문구 추가", for: .normal)
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
        
        setupUI()
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
        
        // Output
        
    }

    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 24
        layout.minimumInteritemSpacing = 24
        return layout
    }
}

extension CommentPresetBottomSheet: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.output.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cellViewModel = viewModel.output.dataSource[safe: indexPath.item] else {
            return BaseCollectionViewCell()
        }
        let cell: CommentPresetCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.bind(viewModel: cellViewModel)
        return cell
    }
}

