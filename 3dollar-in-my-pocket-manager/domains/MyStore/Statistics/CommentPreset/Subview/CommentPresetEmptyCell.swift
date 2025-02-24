import UIKit

final class CommentPresetEmptyCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 160
    }
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray50
        label.font = .regular(size: 14)
        label.numberOfLines = 0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 20
        paragraphStyle.maximumLineHeight = 20
        paragraphStyle.alignment = .center
        let text = Strings.CommentPresetBottomSheet.Empty.title
        let attributesString = NSMutableAttributedString(
            string: text,
            attributes: [ .paragraphStyle: paragraphStyle]
        )
        label.attributedText = attributesString
        return label
    }()
    
    override func setup() {
        contentView.addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
}
