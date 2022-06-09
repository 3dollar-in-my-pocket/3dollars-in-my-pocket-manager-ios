import UIKit

import RxSwift
import RxCocoa

final class CategorySelectView: BaseView {
    private let titleLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textColor = .gray100
        $0.text = "signup_category_title".localized
    }
    
    private let requiredDot = UIView().then {
        $0.backgroundColor = .pink
        $0.layer.cornerRadius = 2
    }
    
    private let descriptionLabel = UILabel().then {
        $0.textColor = .pink
        $0.font = .bold(size: 12)
        $0.text = "signup_category_description".localized
    }
    
    let categoryCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then {
        let layout = LeftAlignedCollectionViewFlowLayout()
        
        layout.minimumInteritemSpacing = 11
        layout.minimumLineSpacing = 12
        layout.estimatedItemSize = SignupCategoryCollectionViewCell.estimatedSize
        $0.collectionViewLayout = layout
        $0.register(
            SignupCategoryCollectionViewCell.self,
            forCellWithReuseIdentifier: SignupCategoryCollectionViewCell.registerID
        )
        $0.allowsMultipleSelection = true
        $0.backgroundColor = .clear
    }
    
    override func setup() {
        self.addSubViews([
            self.titleLabel,
            self.requiredDot,
            self.descriptionLabel,
            self.categoryCollectionView
        ])
        self.categoryCollectionView.delegate = self
    }
    
    override func bindConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        self.requiredDot.snp.makeConstraints { make in
            make.left.equalTo(self.titleLabel.snp.right).offset(4)
            make.top.equalTo(self.titleLabel)
            make.width.height.equalTo(4)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.titleLabel)
            make.right.equalToSuperview()
        }
        
        self.categoryCollectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
            make.height.equalTo(0)
        }
        
        self.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel).priority(.high)
            make.bottom.equalTo(self.categoryCollectionView).priority(.high)
        }
    }
    
    func updateCollectionViewHeight(categories: [StoreCategory]) {
        let maxWidth = UIScreen.main.bounds.width - 48
        let spaceBetweenCells: CGFloat = 11
        var height: CGFloat = SignupCategoryCollectionViewCell.estimatedSize.height
        var currentWidth: CGFloat = 0
        
        for category in categories {
            let stringWidth = (category.name as NSString).size(withAttributes: [
                .font: UIFont.regular(size: 14) as Any
            ]).width
            let cellWidth = stringWidth + 32
            
            if currentWidth + cellWidth >= maxWidth { // 셀 포함해서 한줄 넘어가는 경우
                currentWidth = cellWidth + spaceBetweenCells
                height += SignupCategoryCollectionViewCell.estimatedSize.height + 12
            } else {
                currentWidth = currentWidth + cellWidth + spaceBetweenCells
            }
        }
        
        self.categoryCollectionView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
    }
}

extension CategorySelectView: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        if let selectedCount = collectionView.indexPathsForSelectedItems?.count {
            return selectedCount < 3
        } else {
            return true
        }
    }
}
