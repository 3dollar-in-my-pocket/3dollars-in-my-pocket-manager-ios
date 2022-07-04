import UIKit

import Base

final class FAQView: BaseView {
    let backButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .white
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .semiBold(size: 16)
        $0.textColor = .white
        $0.text = "faq_title".localized
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .medium(size: 24)
        $0.textColor = .white
        $0.text = "faq_description".localized
    }
    
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    ).then {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let item = NSCollectionLayoutItem(layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(FAQCollectionViewCell.height)
            ))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(FAQCollectionViewCell.height)
                ), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            
            section.boundarySupplementaryItems = [.init(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(FAQHeaderView.height)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .topLeading
            )]
            
            return section
        }
        
        $0.collectionViewLayout = layout
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.register(
            FAQCollectionViewCell.self,
            forCellWithReuseIdentifier: FAQCollectionViewCell.registerId
        )
        $0.register(
            FAQHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: FAQHeaderView.registerId
        )
    }
    
    override func setup() {
        self.backgroundColor = .gray100
        self.addSubViews([
            self.backButton,
            self.titleLabel,
            self.descriptionLabel,
            self.collectionView
        ])
    }
    
    override func bindConstraints() {
        self.backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(14)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.backButton)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.backButton.snp.bottom).offset(61)
        }
        
        self.collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.descriptionLabel.snp.bottom).offset(4)
        }
    }
}
