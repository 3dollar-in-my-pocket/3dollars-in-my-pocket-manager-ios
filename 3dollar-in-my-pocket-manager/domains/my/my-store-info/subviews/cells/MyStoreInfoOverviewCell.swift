import UIKit

import Base
import Kingfisher

final class MyStoreInfoOverviewCell: BaseCollectionViewCell {
    static let registerId = "\(MyStoreInfoOverviewCell.self)"
    static let height: CGFloat = 477
    
    private let photoView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .gray5
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 8, height: 8)
        $0.layer.shadowOpacity = 0.04
    }
    
    private let nameLabel = UILabel().then {
        $0.font = .bold(size: 24)
        $0.textColor = .gray100
        $0.textAlignment = .center
    }
    
    private let categoryStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.distribution = .equalSpacing
        $0.alignment = .fill
    }
    
    private let contactContainerView = UIView().then {
        $0.backgroundColor = .gray0
        $0.layer.cornerRadius = 12
    }
    
    private let snsLabel = UILabel().then {
        $0.font = .bold(size: 12)
        $0.textColor = .black
        $0.text = "SNS"
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private let snsValueLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = .gray50
        $0.textAlignment = .right
        $0.numberOfLines = 2
    }
    
    let editButton = UIButton().then {
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.setBackgroundColor(color: .green, forState: .normal)
        $0.setTitle("대표 정보 수정", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .bold(size: 14)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.categoryStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    override func setup() {
        self.addSubViews([
            self.photoView,
            self.containerView,
            self.nameLabel,
            self.categoryStackView,
            self.contactContainerView,
            self.snsLabel,
            self.snsValueLabel,
            self.editButton
        ])
    }
    
    override func bindConstraints() {
        self.photoView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(240)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.photoView.snp.bottom).offset(-30)
            make.bottom.equalToSuperview().offset(-7)
        }
        
        self.nameLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.right.equalTo(self.containerView).offset(-16)
            make.top.equalTo(self.containerView).offset(20)
        }
        
        self.categoryStackView.snp.makeConstraints { make in
            make.centerX.equalTo(self.containerView)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(8)
        }
        
        self.contactContainerView.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.right.equalTo(self.containerView).offset(-16)
            make.top.equalTo(self.categoryStackView.snp.bottom).offset(16)
            make.height.equalTo(78)
        }
        
        self.snsLabel.snp.makeConstraints { make in
            make.left.equalTo(self.contactContainerView).offset(12)
            make.top.equalTo(self.contactContainerView).offset(12)
        }
        
        self.snsValueLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snsLabel)
            make.right.equalTo(self.contactContainerView).offset(-12)
            make.left.equalTo(self.snsLabel.snp.right).offset(12)
        }
        
        self.editButton.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.right.equalTo(self.containerView).offset(-16)
            make.top.equalTo(self.contactContainerView.snp.bottom).offset(16)
            make.height.equalTo(48)
        }
    }
    
    func bind(store: Store) {
        self.nameLabel.text = store.name
        self.photoView.setImage(urlString: store.imageUrl)
        
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
            
            self.categoryStackView.addArrangedSubview(categoryLagel)
        }
        
        self.snsValueLabel.text = store.snsUrl
    }
}
