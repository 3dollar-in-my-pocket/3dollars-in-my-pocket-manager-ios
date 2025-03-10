import UIKit

final class TitleBadgeView: BaseView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.layoutMargins = .init(top: 2, left: 4, bottom: 2, right: 4)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layer.cornerRadius = 4
        stackView.layer.masksToBounds = true
        stackView.backgroundColor = .pink100
        return stackView
    }()
    
    private let medalImageView = UIImageView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .pink
        label.font = .medium(size: 10)
        return label
    }()
    
    override func setup() {
        addSubview(stackView)
        stackView.addArrangedSubview(medalImageView)
        stackView.addArrangedSubview(titleLabel)
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        medalImageView.snp.makeConstraints {
            $0.size.equalTo(16)
        }
        
        snp.makeConstraints {
            $0.edges.equalTo(stackView)
        }
    }
    
    func bind(medal: MedalResponse) {
        titleLabel.text = medal.name
        medalImageView.setImage(urlString: medal.iconUrl)
    }
}
