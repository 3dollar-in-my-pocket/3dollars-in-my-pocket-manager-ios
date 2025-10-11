
import Foundation
import UIKit

final class CouponEmptyCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 346
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 16)
        label.attributedText = Self.makeTitleAttributedText()
        return label
    }()
    
    private let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Assets.couponEmpty.image
        return imageView
    }()
    
    override func setup() {
        
        contentView.backgroundColor = .clear
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(emptyImageView)
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(50)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }
    
    static func makeTitleAttributedText() -> NSAttributedString {
        let full = "쿠폰으로 매출도, 단골도 늘려보세요!"
        let attr = NSMutableAttributedString(string: full)

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        attr.addAttributes([
            .font: UIFont.bold(size: 16) ?? .systemFont(ofSize: 16),
            .foregroundColor: UIColor.gray95,
            .paragraphStyle: paragraph
        ], range: NSRange(location: 0, length: attr.length))

        if let range = (full as NSString).range(of: "매출도, 단골도").toOptional() {
            attr.addAttribute(.font, value: UIFont.bold(size: 16) ?? .systemFont(ofSize: 16), range: range)
            attr.addAttribute(.foregroundColor, value: UIColor.green, range: range)
        }
        return attr
    }
}
