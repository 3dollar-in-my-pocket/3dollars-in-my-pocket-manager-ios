import UIKit

final class SignupCategoryCollectionViewCell: BaseCollectionViewCell {
    static let registerID = "\(SignupCategoryCollectionViewCell.self)"
    static let estimatedSize = CGSize(width: 56, height: 40)
    
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = self.isSelected
            ? .green
            : UIColor(r: 242, g: 251, b: 247)
            self.titleLabel.textColor = self.isSelected
            ? .white
            : .green
        }
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .green
        $0.font = .regular(size: 14)
    }
    
    override func setup() {
        self.layer.cornerRadius = 8
        self.addSubViews([
            self.titleLabel
        ])
    }
    
    override func bindConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func bind(category: StoreCategory) {
        self.titleLabel.text = category.name
    }
}
