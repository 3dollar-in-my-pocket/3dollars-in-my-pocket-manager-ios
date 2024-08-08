import UIKit

import Kingfisher

final class MyStoreInfoOverviewCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 477
    }
    
    private let photoView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .gray5
        return imageView
    }()
    
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
        label.text = "SNS"
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
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.setBackgroundColor(color: .green, forState: .normal)
        button.setTitle("대표 정보 수정", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .bold(size: 14)
        return button
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        categoryStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        photoView.clear()
    }
    
    override func setup() {
        addSubViews([
            photoView,
            containerView,
            nameLabel,
            categoryStackView,
            contactContainerView,
            snsLabel,
            snsValueLabel,
            editButton
        ])
        
        photoView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(240)
        }
        
        containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(photoView.snp.bottom).offset(-30)
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
    
    func bindPhotoConstraintAgain(height: CGFloat) {
        photoView.snp.remakeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            if height >= 0 {
                make.height.equalTo(240)
                make.top.equalToSuperview()
            } else {
                make.height.equalTo(240-height)
                make.top.equalToSuperview().offset(height)
            }
        }
    }
    
    func bind(store: BossStoreInfoResponse) {
        nameLabel.text = store.name
        photoView.setImage(urlString: store.imageUrl)
        
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
}
