import UIKit
import Combine

final class CouponTabButton: BaseView {
    let tapPublisher = PassthroughSubject<CouponTabType, Never>()
    
    enum CouponTabType {
        case active
        case nonActive
        
        var name: String {
            switch self {
            case .active:
                return "active"
            case .nonActive:
                return "nonActive"
            }
        }
    }
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray5
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let activeButton: UIButton = {
        let button = UIButton()
        button.setTitle("발급 / 사용 중 쿠폰", for: .normal)
        button.setTitleColor(.gray100, for: .selected)
        button.setTitleColor(.gray40, for: .normal)
        button.titleLabel?.font = .semiBold(size: 14)
        button.isSelected = true
        return button
    }()
    
    private let nonActiveButton: UIButton = {
        let button = UIButton()
        button.setTitle("종료된 쿠폰", for: .normal)
        button.setTitleColor(.gray100, for: .selected)
        button.setTitleColor(.gray40, for: .normal)
        button.titleLabel?.font = .semiBold(size: 14)
        return button
    }()
    
    override func setup() {
        backgroundColor = .clear
        setupLayout()
        bind()
    }
    
    private func setupLayout() {
        addSubViews([
            backgroundView,
            indicatorView,
            activeButton,
            nonActiveButton
        ])
        
        backgroundView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(44)
        }
        
        activeButton.snp.makeConstraints {
            $0.leading.equalTo(backgroundView).offset(4)
            $0.top.equalTo(backgroundView).offset(4)
            $0.bottom.equalTo(backgroundView).offset(-4)
            $0.trailing.equalTo(snp.centerX).offset(-3)
        }
        
        nonActiveButton.snp.makeConstraints {
            $0.leading.equalTo(snp.centerX).offset(3)
            $0.top.equalTo(activeButton)
            $0.bottom.equalTo(activeButton)
            $0.trailing.equalTo(backgroundView).offset(-4)
        }
        
        indicatorView.snp.makeConstraints {
            $0.edges.equalTo(activeButton)
        }
        
        snp.makeConstraints {
            $0.edges.equalTo(backgroundView).priority(.high)
        }
    }
    
    private func bind() {
        Publishers.Merge(
            activeButton.tapPublisher.map { CouponTabType.active },
            nonActiveButton.tapPublisher.map { CouponTabType.nonActive }
        )
        .throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: false)
        .main
        .withUnretained(self)
        .sink(receiveValue: { (owner: CouponTabButton, filterType: CouponTabType) in
            owner.selectButton(type: filterType)
            owner.tapPublisher.send(filterType)
        })
        .store(in: &cancellables)
    }
    
    private func selectButton(type: CouponTabType) {
        activeButton.isSelected = type == .active
        activeButton.titleLabel?.font = activeButton.isSelected ? .semiBold(size: 14) : .regular(size: 14)
        nonActiveButton.isSelected = type == .nonActive
        nonActiveButton.titleLabel?.font = nonActiveButton.isSelected ? .semiBold(size: 14) : .regular(size: 14)
        indicatorView.snp.remakeConstraints { make in
            make.edges.equalTo(type == .active ? activeButton : nonActiveButton)
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.layoutIfNeeded()
        }
    }
}
