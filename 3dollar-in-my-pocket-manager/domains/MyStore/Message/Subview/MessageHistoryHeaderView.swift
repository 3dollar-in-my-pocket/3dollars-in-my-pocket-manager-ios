import UIKit

final class MessageHistoryHeaderView: UICollectionReusableView {
    enum Layout {
        static let height: CGFloat = 60
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .bold(size: 16)
        label.textColor = .gray95
        label.text = Strings.Message.Message.headerTitle
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview().offset(24)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
}
