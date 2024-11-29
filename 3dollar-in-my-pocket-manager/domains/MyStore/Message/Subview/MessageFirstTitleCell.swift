import UIKit

final class MessageFirstTitleCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 160
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    override func setup() {
        setupUI()
    }
    
    private func setupUI() {
        stackView.addArrangedSubview(createDescriptionLabel(text: Strings.Message.FirstTitle.Description.first))
        stackView.addArrangedSubview(createStackLabel(
            text: Strings.Message.FirstTitle.Description.second,
            coloredText: Strings.Message.FirstTitle.Description.Second.colord
        ))
        stackView.addArrangedSubview(createDescriptionLabel(
            text: Strings.Message.FirstTitle.Description.third,
            coloredText: Strings.Message.FirstTitle.Description.Third.colored
        ))
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
    }
    
    private func createDescriptionLabel(text: String, coloredText: String? = nil) -> UILabel {
        let label = UILabel()
        label.font = .bold(size: 24)
        label.textColor = .gray95
        
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = 32
        style.minimumLineHeight = 32
        let attributedString = NSMutableAttributedString(string: text, attributes: [.paragraphStyle: style])
        
        if let coloredText {
            let colorRange = (text as NSString).range(of: coloredText)
            attributedString.addAttribute(.foregroundColor, value: UIColor.green, range: colorRange)
        }
        
        label.attributedText = attributedString
        label.numberOfLines = 0
        return label
    }
    
    private func createStackLabel(text: String, coloredText: String? = nil) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        
        let icon = UIImageView()
        icon.image = Assets.icBookmarkSolid.image.resizeImage(scaledTo: 27).withRenderingMode(.alwaysTemplate)
        icon.tintColor = .green
        stackView.addArrangedSubview(icon)
        icon.snp.makeConstraints {
            $0.size.equalTo(27)
        }
        
        let label = createDescriptionLabel(text: text, coloredText: coloredText)
        stackView.addArrangedSubview(label)
        return stackView
    }
}
