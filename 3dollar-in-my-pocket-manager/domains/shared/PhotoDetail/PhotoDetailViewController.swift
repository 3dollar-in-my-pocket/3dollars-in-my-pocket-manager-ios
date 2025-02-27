import UIKit

import CombineCocoa

final class PhotoDetailViewController: BaseViewController {
    private let closeButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = Assets.icClose.image.resizeImage(scaledTo: 24).withRenderingMode(.alwaysTemplate)
        let button = UIButton(configuration: config)
        button.tintColor = .white
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.register([BaseCollectionViewCell.self, PhotoDetailCell.self])
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let previousButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = Assets.icArrowLeft.image.resizeImage(scaledTo: 20).withRenderingMode(.alwaysTemplate)
        let button = UIButton(configuration: config)
        button.tintColor = .green
        button.backgroundColor = .gray95
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    private let nextButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = Assets.icArrowRight.image.resizeImage(scaledTo: 20).withRenderingMode(.alwaysTemplate)
        let button = UIButton(configuration: config)
        button.tintColor = .green
        button.backgroundColor = .gray95
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 14)
        label.textColor = .gray10
        return label
    }()
    
    private let viewModel: PhotoDetailViewModel
    
    init(viewModel: PhotoDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }
    
    private func setupUI() {
        view.backgroundColor = .gray100
        view.addSubview(closeButton)
        view.addSubview(previousButton)
        view.addSubview(countLabel)
        view.addSubview(nextButton)
        view.addSubview(collectionView)
        
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.size.equalTo(24)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(previousButton.snp.top).offset(-16)
            $0.top.equalTo(closeButton.snp.bottom).offset(32)
        }
        
        countLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-28)
        }
        
        previousButton.snp.makeConstraints {
            $0.centerY.equalTo(countLabel)
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(44)
        }
        
        nextButton.snp.makeConstraints {
            $0.centerY.equalTo(countLabel)
            $0.trailing.equalToSuperview().offset(-20)
            $0.size.equalTo(44)
        }
    }
    
    private func bind() {
        // Input
        closeButton.tapPublisher
            .throttleClick()
            .withUnretained(self)
            .sink { (owner: PhotoDetailViewController, _) in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
        
        previousButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapPrevious)
            .store(in: &cancellables)
        
        nextButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapNext)
            .store(in: &cancellables)
        
        collectionView.didEndDeceleratingPublisher
            .withUnretained(self)
            .sink { (owner: PhotoDetailViewController, _) in
                let index = Int(owner.collectionView.contentOffset.x / PhotoDetailCell.Layout.size.width)
                owner.viewModel.input.didScroll.send(index)
            }
            .store(in: &cancellables)
        
        // Output
        viewModel.output.currentIndex
            .main
            .withUnretained(self)
            .sink { (owner: PhotoDetailViewController, currentIndex: Int) in
                owner.countLabel.text = "\(currentIndex + 1) / \(owner.viewModel.output.images.count)"
            }
            .store(in: &cancellables)
        
        viewModel.output.scrollToIndex
            .first()
            .main
            .withUnretained(self)
            .sink { (owner: PhotoDetailViewController, index: Int) in
                guard index >= 0, index < owner.viewModel.output.images.count else { return }
                
                DispatchQueue.main.async {
                    let xOffset = CGFloat(index) * PhotoDetailCell.Layout.size.width
                    owner.collectionView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: false)
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.scrollToIndex
            .dropFirst()
            .main
            .withUnretained(self)
            .sink { (owner: PhotoDetailViewController, index: Int) in
                guard index >= 0, index < owner.viewModel.output.images.count else { return }
                
                DispatchQueue.main.async {
                    let xOffset = CGFloat(index) * PhotoDetailCell.Layout.size.width
                    owner.collectionView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: true)
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.isHiddenPrevious
            .main
            .withUnretained(self)
            .sink { (owner: PhotoDetailViewController, isHidden: Bool) in
                owner.previousButton.isHidden = isHidden
            }
            .store(in: &cancellables)
        
        viewModel.output.isHiddenNext
            .main
            .withUnretained(self)
            .sink { (owner: PhotoDetailViewController, isHidden: Bool) in
                owner.nextButton.isHidden = isHidden
            }
            .store(in: &cancellables)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = PhotoDetailCell.Layout.size
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        return layout
    }
}

extension PhotoDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let image = viewModel.output.images[safe: indexPath.item] else { return BaseCollectionViewCell() }
        let cell: PhotoDetailCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.bind(imageUrl: image.imageUrl)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.output.images.count
    }
}
