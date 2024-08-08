import UIKit
import Combine

final class MyStoreInfoHeaderView: UICollectionReusableView {
    enum Layout {
        static let height: CGFloat = 69
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .extraBold(size: 18)
        label.textColor = .gray95
        return label
    }()
    
    let rightButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.green, for: .normal)
        button.titleLabel?.font = .bold(size: 12)
        return button
    }()
    
    var cancellables = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(sectionType: MyStoreInfoSection.SectionType) {
        titleLabel.text = sectionType.title
        rightButton.setTitle(sectionType.rightButtonTitle, for: .normal)
    }
    
    private func setup() {
        addSubViews([
            titleLabel,
            rightButton
        ])
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(37)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        rightButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalTo(titleLabel)
        }
    }
}

private extension MyStoreInfoSection.SectionType {
    var title: String {
        switch self {
        case .introduction:
            return "my_store_info_header_introduction".localized
        case .menu:
            return "my_store_info_header_menus".localized
        case .account:
            return "my_store_info_header_account".localized
        case .appearanceDay:
            return "my_store_info_header_appearance_day".localized
        default:
            return ""
        }
    }
    
    var rightButtonTitle: String {
        switch self {
        case .introduction:
            return "my_store_info_header_introduction_button".localized
        case .menu:
            return "my_store_info_header_menus_button".localized
        case .account:
            return "my_store_info_header_account_button".localized
        case .appearanceDay:
            return "my_store_info_header_appearance_day_button".localized
        default:
            return ""
        }
    }
}
