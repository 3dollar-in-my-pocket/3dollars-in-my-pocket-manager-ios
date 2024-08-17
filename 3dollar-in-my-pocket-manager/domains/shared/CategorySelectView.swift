import UIKit
import Combine

import CombineCocoa

final class CategorySelectView: BaseView {
    enum Constant {
        static let maxCategoryCount = 3
    }
    
    enum Layout {
        static let itemSpacing: CGFloat = 11
        static let lineSpacing: CGFloat = 12
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 14)
        label.textColor = .gray100
        label.text = "signup_category_title".localized
        return label
    }()
    
    private let requiredDot: UIView = {
        let view = UIView()
        view.backgroundColor = .pink
        view.layer.cornerRadius = 2
        return view
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .pink
        label.font = .bold(size: 12)
        label.text = "signup_category_description".localized
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.allowsMultipleSelection = true
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private var datasource: [StoreFoodCategoryResponse] = []
    
    override func setup() {
        setupLayout()
        
        collectionView.dataSource = self
        collectionView.register([
            CategoryViewCell.self,
            BaseCollectionViewCell.self
        ])
    }
    
    private func setupLayout() {
        addSubViews([
            titleLabel,
            requiredDot,
            descriptionLabel,
            collectionView
        ])
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview()
        }
        
        requiredDot.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(4)
            $0.top.equalTo(titleLabel)
            $0.width.height.equalTo(4)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.height.equalTo(0)
        }
        
        snp.makeConstraints {
            $0.top.equalTo(titleLabel).priority(.high)
            $0.bottom.equalTo(collectionView).priority(.high)
        }
    }
    
    func bind(categories: [StoreFoodCategoryResponse]) {
        updateHeight(categories: categories)
        datasource = categories
        collectionView.reloadData()
    }
    
    func selectCategories(categories: [StoreFoodCategoryResponse]) {
        for category in categories {
            if let targetIndex = datasource.firstIndex(of: category) {
                collectionView.selectItem(
                    at: IndexPath(item: targetIndex, section: 0),
                    animated: false,
                    scrollPosition: .centeredVertically
                )
            }
        }
    }
    
    @available(*, deprecated)
    func updateCollectionViewHeight(categories: [StoreCategory]) {
        let maxWidth = UIScreen.main.bounds.width - 48
        let spaceBetweenCells: CGFloat = 11
        var totalHeight: CGFloat = CategoryViewCell.Layout.height
        var currentWidth: CGFloat = 0
        
        for category in categories {
            let stringWidth = (category.name as NSString)
                .size(withAttributes: [.font: UIFont.regular(size: 14) as Any])
                .width
            let cellWidth = stringWidth + 36
            
            if currentWidth + cellWidth >= maxWidth { // 셀 포함해서 한줄 넘어가는 경우
                currentWidth = cellWidth + spaceBetweenCells
                totalHeight += CategoryViewCell.Layout.height + Layout.lineSpacing
            } else {
                currentWidth = currentWidth + cellWidth + spaceBetweenCells
            }
        }
        
        collectionView.snp.updateConstraints { make in
            make.height.equalTo(totalHeight)
        }
    }
    
    func updateHeight(categories: [StoreFoodCategoryResponse]) {
        let maxWidth = UIScreen.main.bounds.width - 48
        let spaceBetweenCells: CGFloat = 11
        var totalHeight: CGFloat = CategoryViewCell.Layout.height
        var currentWidth: CGFloat = 0
        
        for category in categories {
            let stringWidth = (category.name as NSString)
                .size(withAttributes: [.font: UIFont.regular(size: 14) as Any])
                .width
            let cellWidth = stringWidth + 36
            
            if currentWidth + cellWidth >= maxWidth { // 셀 포함해서 한줄 넘어가는 경우
                currentWidth = cellWidth + spaceBetweenCells
                totalHeight += CategoryViewCell.Layout.height + Layout.lineSpacing
            } else {
                currentWidth = currentWidth + cellWidth + spaceBetweenCells
            }
        }
        
        collectionView.snp.updateConstraints { make in
            make.height.equalTo(totalHeight)
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = LeftAlignedCollectionViewFlowLayout()
        
        layout.minimumInteritemSpacing = Layout.itemSpacing
        layout.minimumLineSpacing = Layout.lineSpacing
        layout.estimatedItemSize = CategoryViewCell.Layout.estimatedSize
        return layout
    }
}

extension CategorySelectView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let category = datasource[safe: indexPath.item] else { return BaseCollectionViewCell() }
        let cell: CategoryViewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        
        cell.bind(category: category)
        return cell
    }
}


extension CategorySelectView {
    var didSelectItemPublisher: AnyPublisher<IndexPath, Never> {
        return collectionView.didSelectItemPublisher
    }
    
    var didDeselectItemPublisher: AnyPublisher<IndexPath, Never> {
        return collectionView.didDeselectItemPublisher
    }
}
