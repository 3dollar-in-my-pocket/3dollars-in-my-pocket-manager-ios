import UIKit
import Combine

final class EditStoreInfoPhotoView: BaseView {
    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width, height: 322)
    }
    
    let didTapDeletePhoto = PassthroughSubject<Int, Never>()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 14)
        label.textColor = .gray100
        label.text = "edit_store_info.photo_title".localized
        return label
    }()
    
    private let redDot: UIView = {
        let view = UIView()
        view.backgroundColor = .pink
        view.layer.cornerRadius = 2
        return view
    }()
    
    private let mainPhotoView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.backgroundColor = .gray10
        return imageView
    }()
    
    private let representativeLabel = RepresentativeLabel()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private var datasource: [BossStoreImage] = []
    
    override func setup() {
        setupLayout()
        
        collectionView.register([
            BaseCollectionViewCell.self,
            EditStoreInfoPhotoCell.self,
            EditStoreInfoPhotoCountCell.self
        ])
        collectionView.dataSource = self
    }
    
    func bind(images: [BossStoreImage]) {
        if let mainPhoto = images.first {
            if let photoUrl = mainPhoto.imageUrl {
                mainPhotoView.setImage(urlString: photoUrl)
            } else if let image = mainPhoto.image {
                mainPhotoView.image = image
            }
        }
        
        datasource = images
        collectionView.reloadData()
    }
    
    private func setupLayout() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview()
        }
        
        addSubview(redDot)
        redDot.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(4)
            $0.top.equalTo(titleLabel)
            $0.size.equalTo(4)
        }
        
        addSubview(mainPhotoView)
        mainPhotoView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.height.equalTo(204)
        }
        
        addSubview(representativeLabel)
        representativeLabel.snp.makeConstraints {
            $0.leading.equalTo(mainPhotoView).offset(8)
            $0.top.equalTo(mainPhotoView).offset(8)
        }
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(mainPhotoView.snp.bottom).offset(14)
            $0.height.equalTo(76)
        }
        
        snp.makeConstraints {
            $0.size.equalTo(Layout.size)
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = EditStoreInfoPhotoCell.Layout.size
        layout.minimumInteritemSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        return layout
    }
}

extension EditStoreInfoPhotoView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let countCell: EditStoreInfoPhotoCountCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            countCell.bind(count: datasource.count)
            return countCell
        } else {
            guard let image = datasource[safe: indexPath.item - 1] else { return BaseCollectionViewCell() }
            let photoCell: EditStoreInfoPhotoCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            photoCell.bind(image, isLastOne: datasource.count == 1)
            photoCell.deleteButton.tapPublisher
                .map { _ in indexPath.item - 1 }
                .subscribe(didTapDeletePhoto)
                .store(in: &photoCell.cancellables)
            return photoCell
        }
    }
}
