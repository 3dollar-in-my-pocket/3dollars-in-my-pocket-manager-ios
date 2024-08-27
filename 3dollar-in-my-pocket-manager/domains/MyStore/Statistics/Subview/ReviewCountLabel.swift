import UIKit

final class ReviewCountLabel: BaseView {
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 24)
        label.textColor = .gray95
        label.text = "총"
        return label
    }()
    
    fileprivate let countLabel: PaddingLabel = {
        let label = PaddingLabel(
            topInset: 4,
            bottomInset: 4,
            leftInset: 8,
            rightInset: 8
        )
        label.font = .extraBold(size: 18)
        label.textColor = .green
        label.backgroundColor = UIColor(r: 225, g: 243, b: 234)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }()
    
    private let ofLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 24)
        label.textColor = .gray95
        label.text = "의"
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 24)
        label.textColor = .gray95
        label.text = "statistics_review_count".localized
        return label
    }()
    
    override func setup() {
        setupLayout()
    }
    
    private func setupLayout() {
        addSubViews([
            totalLabel,
            countLabel,
            ofLabel,
            descriptionLabel
        ])
        
        totalLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints {
            $0.leading.equalTo(totalLabel.snp.trailing).offset(6)
            $0.centerY.equalTo(totalLabel)
            $0.height.equalTo(28)
        }
        
        ofLabel.snp.makeConstraints {
            $0.centerY.equalTo(countLabel)
            $0.leading.equalTo(countLabel.snp.trailing).offset(4)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalTo(totalLabel)
            $0.top.equalTo(totalLabel.snp.bottom).offset(4)
        }
        
        snp.makeConstraints {
            $0.leading.equalTo(totalLabel).priority(.high)
            $0.top.equalTo(totalLabel).priority(.high)
            $0.trailing.equalTo(descriptionLabel).priority(.high)
            $0.bottom.equalTo(descriptionLabel).priority(.high)
        }
    }
    
    func bind(_ count: Int) {
        countLabel.text = "\(count)개"
    }
}
