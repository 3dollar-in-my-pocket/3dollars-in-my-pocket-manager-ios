import UIKit

final class SpeechBubbleCell: BaseCollectionViewCell {
    enum Layout {
        static func containerSize(message: String) -> CGSize {
            let messageSize = messageSize(message: message)
            
            return CGSize(width: messageSize.width + 28, height: messageSize.height + 24)
        }
        
        static func messageSize(message: String) -> CGSize {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = 24
            paragraphStyle.maximumLineHeight = 24
            
            let attributedString = NSAttributedString(string: message, attributes: [
                .font: UIFont.medium(size: 16) as Any,
                .paragraphStyle: paragraphStyle,
                .kern: 16 * (-1 / 100)
            ])
            return attributedString.size(maxWidth: UIUtils.windowBounds.width - 40)
        }
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .medium(size: 16)
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    override func setup() {
        super.setup()
        
        contentView.addSubview(containerView)
        containerView.addSubview(messageLabel)
    }
    
    override func bindConstraints() {
        super.bindConstraints()
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(0)
        }
        
        messageLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-14)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
    
    func bind(viewModel: SpeechBubbleCellViewModel) {
        bindMessage(viewModel: viewModel)
        
        containerView.snp.updateConstraints {
            $0.width.equalTo(Layout.containerSize(message: viewModel.output.text))
        }
    }
    
    private func bindMessage(viewModel: SpeechBubbleCellViewModel) {
        let text = viewModel.output.text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 24
        paragraphStyle.maximumLineHeight = 24
        paragraphStyle.paragraphSpacing = -1
        
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont.medium(size: 16) as Any,
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle,
            .kern: 16 * (-1 / 100)
        ])
        
        if let boldText = viewModel.output.boldText {
            let range = (text as NSString).range(of: boldText)
            attributedString.addAttribute(.font, value: UIFont.bold(size: 16) as Any, range: range)
        }
        
        messageLabel.attributedText = attributedString
    }
}
