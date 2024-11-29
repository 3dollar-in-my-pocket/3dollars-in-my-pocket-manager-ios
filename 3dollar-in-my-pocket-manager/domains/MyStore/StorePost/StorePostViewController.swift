import UIKit
import Combine

import CombineCocoa

final class StorePostViewController: BaseViewController {
    private var viewModel: StorePostViewModel
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register([
            BaseCollectionViewCell.self,
            StorePostCell.self
        ])
        return collectionView
    }()
    
    private let uploadButton: UIButton = {
        let button = UIButton()
        button.layer.shadowColor = UIColor.green.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.4
        button.backgroundColor = .green
        button.layer.cornerRadius = 22
        
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = .init(
            "store_post.upload".localizable,
            attributes: .init([
                .font: UIFont.medium(size: 14) as Any,
                .foregroundColor: UIColor.white
            ]))
        configuration.baseForegroundColor = .white
        configuration.image = UIImage(named: "ic_write_solid")
        configuration.imagePadding = 4
        configuration.contentInsets = .init(top: 12, leading: 16, bottom: 12, trailing: 16)
        button.configuration = configuration
        return button
    }()
    
    private let emptyView: StorePostEmptyView = {
        let emptyView = StorePostEmptyView()
        
        emptyView.isHidden = true
        return emptyView
    }()
    
    private var dataSource: [StorePostCellViewModel] = []
    private var isFirstLoad = true
    
    init(viewModel: StorePostViewModel = StorePostViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        setupUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstLoad {
            viewModel.input.firstLoad.send(())
            isFirstLoad = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(emptyView)
        emptyView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(uploadButton)
        uploadButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            $0.height.equalTo(44)
        }
    }
    
    private func bind() {
        // Intput
        uploadButton.tapPublisher
            .mapVoid
            .subscribe(viewModel.input.didTapWrite)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.postCellViewModelList
            .main
            .withUnretained(self)
            .sink { (owner: StorePostViewController, dataSource: [StorePostCellViewModel]) in
                owner.emptyView.isHidden = dataSource.isNotEmpty
                owner.dataSource = dataSource
                owner.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink(receiveValue: { (owner: StorePostViewController, route: StorePostViewModel.Route) in
                switch route {
                case .pushUpload(let viewModel):
                    owner.pushUploadPost(viewModel: viewModel)
                case .pushEdit(let viewModel):
                    owner.pushEditPost(viewModel: viewModel)
                case .showErrorAlert(let error):
                    owner.showErrorAlert(error: error)
                }
            })
            .store(in: &cancellables)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .vertical
        return layout
    }
    
    private func pushUploadPost(viewModel: UploadPostViewModel) {
        let viewController = UploadPostViewController(viewModel: viewModel)
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func pushEditPost(viewModel: UploadPostViewModel) {
        let viewController = UploadPostViewController(viewModel: viewModel)
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension StorePostViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let storePost = dataSource[safe: indexPath.item] else { return BaseCollectionViewCell() }
        let cell: StorePostCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        
        cell.bind(storePost)
        return cell
    }
}

extension StorePostViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let storePost = dataSource[safe: indexPath.item]?.output.storePost else { return .zero }
        let height = StorePostCell.Layout.calculateHeight(storePost: storePost)
        let width = UIUtils.windowBounds.width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.input.cellWillDisplay.send(indexPath.item)
    }
}
