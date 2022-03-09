import UIKit

import RxSwift
import RxCocoa

final class SignupCategorySelectView: BaseView {
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
    }
    
    override func setup() {
        self.addSubViews([
            self.titleLabel,
            self.requiredDot,
            self.descriptionLabel,
            self.categoryCollectionView
        ])
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
}
