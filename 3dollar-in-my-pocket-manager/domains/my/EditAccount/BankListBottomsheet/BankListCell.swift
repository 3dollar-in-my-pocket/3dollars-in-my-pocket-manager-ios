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
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 12
        view.layer.borderColor = UIColor.gray40.cgColor
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 14)
        label.textColor = .gray50
        return label
    }()
    
    private let checkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_check_line")
        imageView.isHidden = true
        return imageView
    }()
    
    override func setup() {
        setupLayout()
    }
    
    private func setupLayout() {
        contentView.addSubViews([
            containerView,
            titleLabel,
            checkImage
        ])
        
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
    
    func bind(bank: BossBank) {
        titleLabel.text = bank.description
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
