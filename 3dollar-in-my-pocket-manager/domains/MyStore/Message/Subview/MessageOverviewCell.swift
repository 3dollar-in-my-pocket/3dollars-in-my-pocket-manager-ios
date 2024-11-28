import UIKit

final class MessageOverviewCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 188
    }
    
    private let userCountLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 4, bottomInset: 4, leftInset: 8, rightInset: 8)
        label.textColor = .green
        label.font = .bold(size: 16)
        label.backgroundColor = UIColor(hex: "#E1F3EA")
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        return label
    }()
    
    private let firstTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray95
        label.text = Strings.Message.Overview.Title.first
        label.setLineHeight(lineHeight: 32)
        label.setKern(kern: -0.01)
        label.font = .bold(size: 24)
        return label
    }()
    
    private let secondTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray95
        label.text = Strings.Message.Overview.Title.second
        label.setLineHeight(lineHeight: 32)
        label.setKern(kern: -0.01)
        label.font = .bold(size: 24)
        return label
    }()
    
    private let descriptionView = DescriptionView()
    
    override func setup() {
        contentView.addSubViews([
            userCountLabel,
            firstTitleLabel,
            secondTitleLabel,
            descriptionView
        ])
        
        userCountLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview().offset(20)
        }
        
        firstTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(userCountLabel.snp.trailing).offset(4)
            $0.centerY.equalTo(userCountLabel)
        }
        
        secondTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(userCountLabel)
            $0.top.equalTo(userCountLabel.snp.bottom)
            $0.height.equalTo(32)
        }
        
        descriptionView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.top.equalTo(secondTitleLabel.snp.bottom).offset(16)
        }
    }
    
    func bind(count: Int) {
        userCountLabel.text = Strings.Message.Overview.userCountFormat(count)
    }
}

extension MessageOverviewCell {
    final class DescriptionView: UIStackView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            setupUI()
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            spacing = 4
            axis = .vertical
            addArrangedSubview(createDescriptionLabel(text: Strings.Message.Overview.Description.first))
            addArrangedSubview(createDescriptionLabel(
                text: Strings.Message.Overview.Description.second,
                coloredText: Strings.Message.Overview.Description.Second.colored
            ))
            addArrangedSubview(createDescriptionLabel(
                text: Strings.Message.Overview.Description.third,
                coloredText: Strings.Message.Overview.Description.Third.colored
            ))
        }
        
        private func createDescriptionLabel(text: String, coloredText: String? = nil) -> UIStackView {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 4
            
            let icon = UIImageView()
            icon.image = Assets.icInformation.image.resizeImage(scaledTo: 20).withRenderingMode(.alwaysTemplate)
            icon.tintColor = .green
            
            stackView.addArrangedSubview(icon)
            
            icon.snp.makeConstraints {
                $0.size.equalTo(20)
            }
            
            let label = UILabel()
            label.font = .regular(size: 14)
            label.textColor = .gray60
            
            let attributedString = NSMutableAttributedString(string: text)
            
            if let coloredText {
                let colorRange = (text as NSString).range(of: coloredText)
                attributedString.addAttribute(.foregroundColor, value: UIColor.green, range: colorRange)
            }
            label.attributedText = attributedString
            stackView.addArrangedSubview(label)
            
            return stackView
        }
    }
}
