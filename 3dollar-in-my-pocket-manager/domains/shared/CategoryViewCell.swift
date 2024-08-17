import UIKit

final class CategoryViewCell: BaseCollectionViewCell {
    enum Layout {
        static let estimatedSize = CGSize(width: 56, height: 40)
        static let horizontalPadding: CGFloat = 32
        static let height: CGFloat = 40
        static func calculateSize(category: String) -> CGSize {
            let string = NSString(string: category)
            let stringWidth = string.size(withAttributes: [.font: UIFont.regular(size: 15) as Any]).width
            return CGSize(width: stringWidth + horizontalPadding, height: height)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .green : UIColor(r: 242, g: 251, b: 247)
            paddingLabel.textColor = isSelected ? .white : .green
            paddingLabel.font = isSelected ? .bold(size: 14) : .regular(size: 14)
        }
    }
    
    private let paddingLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 10, bottomInset: 10, leftInset: 16, rightInset: 16)
        label.textColor = .green
        label.font = .regular(size: 14)
        label.textAlignment = .center
        return label
    }()
    
    override func setup() {
        backgroundColor = UIColor(r: 242, g: 251, b: 247)
        layer.cornerRadius = 8
        setupLayout()
    }
    
    private func setupLayout() {
        addSubViews([paddingLabel])
        
        paddingLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(category: StoreCategory) {
        paddingLabel.text = category.name
    }
    
    func bind(category: StoreFoodCategoryResponse) {
        paddingLabel.text = category.name
    }
}
