import UIKit

import RxSwift
import RxCocoa

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
    
    override func setup() {
        collectionView.delegate = self
        collectionView.register([SignupCategoryCollectionViewCell.self])
        
        addSubViews([
            titleLabel,
            requiredDot,
            descriptionLabel,
            collectionView
        ])
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        requiredDot.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.right).offset(4)
            make.top.equalTo(titleLabel)
            make.width.height.equalTo(4)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.height.equalTo(0)
        }
        
        snp.makeConstraints { make in
            make.top.equalTo(titleLabel).priority(.high)
            make.bottom.equalTo(collectionView).priority(.high)
        }
    }
    
    func updateCollectionViewHeight(categories: [StoreCategory]) {
        let maxWidth = UIScreen.main.bounds.width - 48
        let spaceBetweenCells: CGFloat = 11
        var height: CGFloat = SignupCategoryCollectionViewCell.Layout.height
        var currentWidth: CGFloat = 0
        
        for category in categories {
            let stringWidth = (category.name as NSString)
                .size(withAttributes: [.font: UIFont.regular(size: 14) as Any])
                .width
            let cellWidth = stringWidth + 36
            
            if currentWidth + cellWidth >= maxWidth { // 셀 포함해서 한줄 넘어가는 경우
                currentWidth = cellWidth + spaceBetweenCells
                height += SignupCategoryCollectionViewCell.Layout.height + Layout.lineSpacing
            } else {
                currentWidth = currentWidth + cellWidth + spaceBetweenCells
            }
        }
        
        collectionView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = LeftAlignedCollectionViewFlowLayout()
        
        layout.minimumInteritemSpacing = Layout.itemSpacing
        layout.minimumLineSpacing = Layout.lineSpacing
        layout.estimatedItemSize = SignupCategoryCollectionViewCell.Layout.estimatedSize
        return layout
    }
}

extension CategorySelectView: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        if let selectedCount = collectionView.indexPathsForSelectedItems?.count {
            return selectedCount < Constant.maxCategoryCount
        } else {
            return true
        }
    }
}
