import UIKit

import CombineCocoa

final class PreferenceViewController: BaseViewController {
    private let viewModel: PreferenceViewModel
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_back"), for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "preference.title".localized
        label.font = .bold(size: 16)
        label.textColor = .gray100
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        return stackView
    }()
    
    private let locationSettingItem = PreferenceItemView(viewType: .location)
    
    private let statusSettingItem = PreferenceItemView(viewType: .status)
    
    init(viewModel: PreferenceViewModel = PreferenceViewModel()) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        viewModel.input.firstLoad.send(())
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        stackView.addArrangedSubview(locationSettingItem)
        stackView.addArrangedSubview(statusSettingItem)
        
        view.addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(21)
            $0.size.equalTo(24)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(backButton.snp.bottom).offset(33)
        }
    }
    
    private func bind() {
        backButton.tapPublisher
            .throttleClick()
            .main
            .withUnretained(self)
            .sink { (owner: PreferenceViewController, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
        
        locationSettingItem.settingSwitch.isOnPublisher
            .dropFirst()
            .mapVoid
            .subscribe(viewModel.input.toggleRemoveLocationOnClose)
            .store(in: &cancellables)
        
        statusSettingItem.settingSwitch.isOnPublisher
            .dropFirst()
            .mapVoid
            .subscribe(viewModel.input.toggleAutoOpenControl)
            .store(in: &cancellables)
        
        viewModel.output.removeLocationOnClose
            .main
            .withUnretained(self)
            .sink { (owner: PreferenceViewController, isOn: Bool) in
                owner.locationSettingItem.settingSwitch.isOn = !isOn
            }
            .store(in: &cancellables)
        
        viewModel.output.autoOpenControl
            .main
            .withUnretained(self)
            .sink { (owner: PreferenceViewController, isOn: Bool) in
                owner.statusSettingItem.settingSwitch.isOn = isOn
            }
            .store(in: &cancellables)
    }
}
