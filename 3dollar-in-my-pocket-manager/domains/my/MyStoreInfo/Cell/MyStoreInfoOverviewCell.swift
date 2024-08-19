import UIKit

import Kingfisher

final class MyStoreInfoOverviewCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 477
    }
    
    private lazy var photoCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .gray5
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    private let photoCountLabel = PhotoCountLabel()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 8, height: 8)
        view.layer.shadowOpacity = 0.04
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 24)
        label.textColor = .gray100
        label.textAlignment = .center
        return label
    }()
    
    private let categoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        return stackView
    }()
    
    private let contactContainerView: UIView =  {
        let view = UIView()
        view.backgroundColor = .gray0
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let snsLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 12)
        label.textColor = .black
        label.text = "edit_store_info.sns".localized
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private let snsValueLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 12)
        label.textColor = .gray50
        label.textAlignment = .right
        label.numberOfLines = 2
        return label
    }()
    
    let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("edit_store_info.title".localized, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.backgroundColor = .green
        button.titleLabel?.font = .bold(size: 14)
        button.adjustsImageWhenHighlighted = false
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private var datasource: [BossStoreImage] = []
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        categoryStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        datasource.removeAll()
    }
    
    override func setup() {
        setupLayout()
        
        photoCollectionView.register([
            OverviewPhotoCell.self,
            BaseCollectionViewCell.self
        ])
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
    }
    
    func bind(store: BossStoreResponse) {
        nameLabel.text = store.name
        datasource = store.representativeImages
        photoCollectionView.reloadData()
        
        for category in store.categories {
            let categoryLagel = PaddingLabel(
                topInset: 4,
                bottomInset: 4,
                leftInset: 8,
                rightInset: 8
            ).then {
                $0.backgroundColor = UIColor(r: 0, g: 198, b: 103, a: 0.1)
                $0.textColor = .green
                $0.layer.cornerRadius = 8
                $0.text = category.name
                $0.layer.masksToBounds = true
                $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            }
            
            categoryStackView.addArrangedSubview(categoryLagel)
        }
        
        snsValueLabel.text = store.snsUrl
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.itemSize = OverviewPhotoCell.Layout.size
        return layout
    }
    
    private func setupLayout() {
        addSubViews([
            photoCollectionView,
            photoCountLabel,
            containerView,
            nameLabel,
            categoryStackView,
            contactContainerView,
            snsLabel,
            snsValueLabel,
            editButton
        ])
        
        photoCollectionView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(240)
        }
        
        photoCountLabel.snp.makeConstraints {
            $0.right.equalTo(photoCollectionView).offset(-24)
            $0.bottom.equalTo(photoCollectionView).offset(-38)
        }
        
        containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(photoCollectionView.snp.bottom).offset(-30)
            make.bottom.equalToSuperview().offset(-7)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(16)
            make.right.equalTo(containerView).offset(-16)
            make.top.equalTo(containerView).offset(20)
        }
        
        categoryStackView.snp.makeConstraints { make in
            make.centerX.equalTo(containerView)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
        }
        
        contactContainerView.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(16)
            make.right.equalTo(containerView).offset(-16)
            make.top.equalTo(categoryStackView.snp.bottom).offset(16)
            make.height.equalTo(78)
        }
        
        snsLabel.snp.makeConstraints { make in
            make.left.equalTo(contactContainerView).offset(12)
            make.top.equalTo(contactContainerView).offset(12)
        }
        
        snsValueLabel.snp.makeConstraints { make in
            make.top.equalTo(snsLabel)
            make.right.equalTo(contactContainerView).offset(-12)
            make.left.equalTo(snsLabel.snp.right).offset(12)
        }
        
        editButton.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(16)
            make.right.equalTo(containerView).offset(-16)
            make.top.equalTo(contactContainerView.snp.bottom).offset(16)
            make.height.equalTo(48)
        }
    }
}

extension MyStoreInfoOverviewCell {
    final class OverviewPhotoCell: BaseCollectionViewCell {
        enum Layout {
            static let size = CGSize(width: UIUtils.windowBounds.width, height: 240)
        }
        
        let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            return imageView
        }()
        
        override func prepareForReuse() {
            super.prepareForReuse()
            imageView.clear()
        }
        
        override func setup() {
            setupLayout()
        }
        
        func bind(photo: BossStoreImage) {
            imageView.setImage(photo)
        }
        
        private func setupLayout() {
            contentView.addSubview(imageView)
            imageView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
    
    final class PhotoCountLabel: BaseView {
        private let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 4
            return stackView
        }()
        
        private let photoIcon: UIImageView = {
            let image = UIImage(named: "ic_camera")?
                .resizeImage(scaledTo: 20)
                .withRenderingMode(.alwaysTemplate)
            let imageView = UIImageView(image: image)
            imageView.tintColor = .white
            return imageView
        }()
        
        private let countLabel: UILabel = {
            let label = UILabel()
            label.textColor = .white
            label.font = .bold(size: 12)
            label.text = "1/10"
            return label
        }()
        
        override func setup() {
            setupLayout()
        }
        
        func bind(count: Int) {
            countLabel.text = "\(count)/10"
        }
        
        private func setupLayout() {
            backgroundColor = .gray80
            layer.cornerRadius = 16
            layer.masksToBounds = true
            
            stackView.addArrangedSubview(photoIcon)
            stackView.addArrangedSubview(countLabel)
            addSubview(stackView)
            stackView.snp.makeConstraints {
                $0.trailing.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
            
            snp.makeConstraints {
                $0.leading.equalTo(stackView).offset(-8)
                $0.trailing.equalTo(stackView).offset(8)
                $0.height.equalTo(32)
            }
        }
    }
}

extension MyStoreInfoOverviewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let image = datasource[safe: indexPath.item] else { return BaseCollectionViewCell() }
        let cell: OverviewPhotoCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        
        cell.bind(photo: image)
        return cell
    }
}

extension MyStoreInfoOverviewCell: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / OverviewPhotoCell.Layout.size.width) + 1
        photoCountLabel.bind(count: index)
    }
}
