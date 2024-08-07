import UIKit

final class PreferenceItemView: BaseView {
    enum Layout {
        static let height: CGFloat = 44
    }
    
    enum ViewType {
        /// 영업 종료시 위치 노출
        case location
        
        /// 영업 상태 자동 변경
        case status
        
        var title: String {
            switch self {
            case .location:
                return "preference.remove_location_on_close.title".localized
            case .status:
                return "preference.auto_open_close_control.title".localized
            }
        }
        
        var description: String {
            switch self {
            case .location:
                return "preference.remove_location_on_close.description".localized
            case .status:
                return "preference.auto_open_close_control.description".localized
            }
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .medium(size: 16)
        label.textColor = .black
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .regular(size: 12)
        label.textColor = .gray50
        return label
    }()
    
    let settingSwitch: UISwitch = {
        let switchView = UISwitch()
        switchView.onTintColor = .green
        switchView.thumbTintColor = .white
        return switchView
    }()
    
    init(viewType: ViewType) {
        super.init(frame: .zero)
        
        bind(viewType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview()
            $0.height.equalTo(21)
        }
        
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.height.equalTo(18)
        }
        
        addSubview(settingSwitch)
        settingSwitch.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-24)
            $0.top.equalTo(titleLabel)
            $0.height.equalTo(24)
        }
        
        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }
    }
    
    private func bind(_ viewType: ViewType) {
        titleLabel.text = viewType.title
        descriptionLabel.text = viewType.description
    }
}
