import UIKit

import CombineCocoa

final class HomeAutoAlertViewController: BaseViewController {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = .init(top: 24, left: 20, bottom: 24, right: 20)
        stackView.backgroundColor = .white
        stackView.layer.cornerRadius = 20
        stackView.layer.masksToBounds = true
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray100
        label.font = .semiBold(size: 20)
        label.text = "home_auto_alert_title".localized
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray50
        label.font = .regular(size: 14)
        label.text = "home_auto_alert_description".localized
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let preferenceButton: UIButton = {
        let button = UIButton()
        button.setTitle("home_auto_alert_go_preference".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .green
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = .bold(size: 14)
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("home_auto_alert_close".localized, for: .normal)
        button.setTitleColor(.green, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.green.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = .bold(size: 14)
        return button
    }()
    
    private var didTapSetting: (() -> Void)
    
    init(didTapSetting: @escaping (() -> Void)) {
        self.didTapSetting = didTapSetting
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }
    
    private func setupUI() {
        if let parentView = presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        stackView.addArrangedSubview(titleLabel)
        stackView.setCustomSpacing(8, after: titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.setCustomSpacing(24, after: descriptionLabel)
        stackView.addArrangedSubview(preferenceButton)
        stackView.setCustomSpacing(8, after: preferenceButton)
        stackView.addArrangedSubview(closeButton)
        
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        preferenceButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        
        closeButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
    }
    
    private func bind() {
        closeButton.tapPublisher
            .throttleClick()
            .withUnretained(self)
            .sink { (owner: HomeAutoAlertViewController, _) in
                DimManager.shared.hideDim()
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
        
        preferenceButton.tapPublisher
            .throttleClick()
            .withUnretained(self)
            .sink { (owner: HomeAutoAlertViewController, _) in
                DimManager.shared.hideDim()
                owner.dismiss(animated: true) { [weak self] in
                    self?.didTapSetting()
                }
            }
            .store(in: &cancellables)
    }
}
