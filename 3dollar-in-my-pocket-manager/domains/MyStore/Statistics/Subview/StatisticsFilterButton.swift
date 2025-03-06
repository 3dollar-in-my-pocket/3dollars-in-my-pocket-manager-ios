import UIKit
import Combine

final class StatisticsFilterButton: BaseView {
    let tapPublisher = PassthroughSubject<FilterType, Never>()
    
    enum FilterType {
        case total
        case day
        
        var name: String {
            switch self {
            case .total:
                return "total"
                
            case .day:
                return "day"
            }
        }
    }
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray5
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 9
        return view
    }()
    
    private let totalButton: UIButton = {
        let button = UIButton()
        button.setTitle("statistics_filter_total".localized, for: .normal)
        button.setTitleColor(.green, for: .selected)
        button.setTitleColor(.gray40, for: .normal)
        button.titleLabel?.font = .medium(size: 14)
        button.isSelected = true
        return button
    }()
    
    private let dayButton: UIButton = {
        let button = UIButton()
        button.setTitle("statistics_filter_day".localized, for: .normal)
        button.setTitleColor(.green, for: .selected)
        button.setTitleColor(.gray40, for: .normal)
        button.titleLabel?.font = .medium(size: 14)
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
            totalButton,
            dayButton
        ])
        
        backgroundView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(56)
        }
        
        totalButton.snp.makeConstraints {
            $0.leading.equalTo(backgroundView).offset(8)
            $0.top.equalTo(backgroundView).offset(8)
            $0.bottom.equalTo(backgroundView).offset(-8)
            $0.trailing.equalTo(snp.centerX).offset(-3)
        }
        
        dayButton.snp.makeConstraints {
            $0.leading.equalTo(snp.centerX).offset(3)
            $0.top.equalTo(totalButton)
            $0.bottom.equalTo(totalButton)
            $0.trailing.equalTo(backgroundView).offset(-8)
        }
        
        indicatorView.snp.makeConstraints {
            $0.edges.equalTo(totalButton)
        }
        
        snp.makeConstraints {
            $0.edges.equalTo(backgroundView).priority(.high)
        }
    }
    
    private func bind() {
        Publishers.Merge(
            totalButton.tapPublisher.map { FilterType.total },
            dayButton.tapPublisher.map { FilterType.day }
        )
        .throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: false)
        .main
        .withUnretained(self)
        .sink(receiveValue: { (owner: StatisticsFilterButton, filterType: FilterType) in
            owner.selectButton(type: filterType)
            owner.tapPublisher.send(filterType)
        })
        .store(in: &cancellables)
    }
    
    private func selectButton(type: FilterType) {
        totalButton.isSelected = type == .total
        dayButton.isSelected = type == .day
        indicatorView.snp.remakeConstraints { make in
            make.edges.equalTo(type == .total ? totalButton : dayButton)
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.layoutIfNeeded()
        }
    }
}
