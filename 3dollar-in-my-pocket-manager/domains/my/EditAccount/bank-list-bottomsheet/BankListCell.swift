import UIKit

final class BankListCell: BaseCollectionViewCell {
    enum Layout {
        static let width: CGFloat = (UIUtils.windowBounds.width - BankListBottomSheetView.Layout.itemSpace - 40) / 2
        static let size = CGSize(width: width, height: 44)
    }
    
    override var isSelected: Bool {
        didSet {
            setSelected(isSelected)
        }
    }
    
    private let containerView = UIView().then {
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 12
        $0.layer.borderColor = UIColor.gray40.cgColor
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .regular(size: 14)
        $0.textColor = .gray50
    }
    
    private let checkImage = UIImageView(image: UIImage(named: "ic_check_line")).then {
        $0.isHidden = true
    }
    
    override func setup() {
        contentView.addSubViews([
            containerView,
            titleLabel,
            checkImage
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(checkImage.snp.leading).offset(-8)
        }
        
        checkImage.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
    }
    
    func bind(item: BankListBottomSheetReactor.Item) {
        titleLabel.text = item.bank.description
        setSelected(item.isSelected)
    }
    
    private func setSelected(_ isSelected: Bool) {
        if isSelected {
            titleLabel.textColor = .black
            containerView.layer.borderColor = UIColor.green.cgColor
            checkImage.isHidden = false
        } else {
            titleLabel.textColor = .gray50
            containerView.layer.borderColor = UIColor.gray40.cgColor
            checkImage.isHidden = true
        }
    }
}
