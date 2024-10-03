import UIKit

import Combine

final class StorePostCell: BaseCollectionViewCell {
    enum Layout {
        static func calculateHeight(storePost: StorePostApiResponse) -> CGFloat {
            var height = calculateBodyHeight(body: storePost.body)
            
            if storePost.sections.isEmpty {
                height += 116
            } else {
                height += 336
            }
            
            return height
        }
        
        static func calculateBodyHeight(body: String) -> CGFloat {
            let label = UILabel()
            label.text = body
            label.numberOfLines = 0
            
            let style = NSMutableParagraphStyle()
            style.maximumLineHeight = 20
            style.minimumLineHeight = 20
            let maxSize = CGSize(width: UIScreen.main.bounds.width, height: CGFloat.greatestFiniteMagnitude)
            let textRect = label.text?.boundingRect(
                with: maxSize,
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [
                    NSAttributedString.Key.font: UIFont.regular(size: 14)!,
                    NSAttributedString.Key.paragraphStyle: style
                ],
                context: nil
            )
            return ceil(textRect?.height ?? .zero)
        }
    }
    
    private let categoryImage: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .gray100
        label.font = .bold(size: 14)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .gray40
        label.font = .regular(size: 12)
        label.textAlignment = .left
        return label
    }()
    
    let moreButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        if let image = UIImage(named: "ic_more")?.withRenderingMode(.alwaysTemplate) {
            configuration.image = image
        }
        configuration.baseForegroundColor = .gray40
        
        return UIButton(configuration: configuration)
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.spacing = 12
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 24)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register([
            BaseCollectionViewCell.self,
            PhotoCell.self
        ])
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let descriptionLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 0, bottomInset: 0, leftInset: 0, rightInset: 24)
        
        label.textColor = .gray95
        label.font = .regular(size: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private let likeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    private let likeImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_heart_fill")?
            .resizeImage(scaledTo: 16)
            .withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .gray50
        return imageView
    }()
    
    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 10)
        label.textColor = .gray60
        return label
    }()
    
    private var viewModel: StorePostCellViewModel?
    private var dataSource: [PostSectionApiResponse] = []
    
    override func setup() {
        contentView.backgroundColor = .white
        contentView.addSubview(categoryImage)
        categoryImage.snp.makeConstraints {
            $0.size.equalTo(40)
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview().offset(16)
        }
        
        contentView.addSubview(moreButton)
        moreButton.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.centerY.equalTo(categoryImage)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(categoryImage.snp.trailing).offset(8)
            $0.trailing.equalTo(moreButton.snp.leading).offset(-8)
            $0.top.equalTo(categoryImage)
            $0.height.equalTo(20)
        }
        
        contentView.addSubview(timestampLabel)
        timestampLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(titleLabel)
            $0.height.equalTo(18)
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.bottom.equalTo(categoryImage)
        }
        
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(categoryImage.snp.bottom).offset(12)
        }
        
        likeStackView.addArrangedSubview(likeImage)
        likeImage.snp.makeConstraints {
            $0.size.equalTo(16)
        }
        likeStackView.addArrangedSubview(likeCountLabel)
        
        moreButton.menu = createMenu()
        moreButton.showsMenuAsPrimaryAction = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        dataSource.removeAll()
        categoryImage.clear()
        stackView.arrangedSubviews.forEach { view in
            view.removeFromSuperview()
        }
    }
    
    func bind(_ viewModel: StorePostCellViewModel) {
        let storePost = viewModel.output.storePost
        if let categoryImageUrl = storePost.store.categories.first?.imageUrl {
            categoryImage.setImage(urlString: categoryImageUrl)
        }
        
        titleLabel.text = storePost.store.storeName
        timestampLabel.text = storePost.createdAt.createdAtFormatted
        descriptionLabel.text = storePost.body
        
        if storePost.sections.isNotEmpty {
            stackView.addArrangedSubview(collectionView)
            collectionView.snp.makeConstraints {
                $0.height.equalTo(PhotoCell.Layout.height)
            }
            
            dataSource = storePost.sections
            collectionView.reloadData()
        }
        
        stackView.addArrangedSubview(descriptionLabel)
        descriptionLabel.setLineHeight(lineHeight: 20)
        
        stackView.addArrangedSubview(likeStackView)
        likeStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
        }
        likeCountLabel.text = "좋아요 \(viewModel.output.storePost.likeCount)"
        
        self.viewModel = viewModel
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        return layout
    }
    
    private func createMenu() -> UIMenu {
        let edit = UIAction(
            title: "store_post_menu.edit".localizable,
            image: UIImage(named: "ic_write_line")?
                .withRenderingMode(.alwaysTemplate)
                .withTintColor(.gray80)
        ) { [weak self] _ in
            self?.viewModel?.input.didTapEdit.send(())
        }
        let delete = UIAction(
            title: "store_post_menu.delete".localizable,
            image: UIImage(named: "ic_trash")?
                .withRenderingMode(.alwaysTemplate)
                .withTintColor(.gray80)
        ) { [weak self] _ in
            self?.showDeleteAlert()
        }
        
        let menu = UIMenu(title: "", children: [edit, delete])
        return menu
    }
    
    private func showDeleteAlert() {
        if let topViewController = UIUtils.topViewController() {
            AlertUtils.showWithCancel(
                viewController: topViewController,
                message: "정말로 삭제하시겠습니까?"
            ) { [weak self] in
                self?.viewModel?.input.didTapDelete.send(())
            }
        }
    }
}

extension StorePostCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = dataSource[safe: indexPath.item] else { return BaseCollectionViewCell() }
        
        let cell: PhotoCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.bind(section.url)
        return cell
    }
}

extension StorePostCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let section = dataSource[safe: indexPath.item] else { return .zero }
        
        return PhotoCell.Layout.calculateSize(ratio: section.ratio)
    }
}

