import UIKit

final class MyStoreInfoIntroductionCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 72
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let introductionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray70
        label.font = .regular(size: 14)
        label.numberOfLines = 0
        label.text = "손님들에게 하고 싶은 말을 적어주세요!\nex) 오전에 오시면 서비스가 있습니다!"
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    override func setup() {
        addSubViews([
            containerView,
            introductionLabel
        ])
        
        containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.bottom.equalTo(introductionLabel).offset(16)
        }
        
        introductionLabel.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(16)
            make.right.equalTo(containerView).offset(-16)
            make.top.equalTo(containerView).offset(16)
        }
    }
    
    func bind(introduction: String?) {
        if let introduction = introduction {
            introductionLabel.text = introduction
        } else {
            introductionLabel.text = "my_store_info_introduction_placeholder".localized
        }
    }
}
