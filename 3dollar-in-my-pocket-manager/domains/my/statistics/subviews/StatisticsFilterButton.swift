import UIKit

import RxSwift
import RxCocoa

final class StatisticsFilterButton: BaseView {
    fileprivate let tapPublisher = PublishSubject<FilterType>()
    
    enum FilterType {
        case total
        case day
    }
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = .gray5
        $0.layer.cornerRadius = 12
    }
    
    private let indicatorView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 9
    }
    
    private let totalButton = UIButton().then {
        $0.setTitle("전체", for: .normal)
        $0.setTitleColor(.green, for: .selected)
        $0.setTitleColor(.gray40, for: .normal)
        $0.titleLabel?.font = .medium(size: 14)
    }
    
    private let dayButton = UIButton().then {
        $0.setTitle("일별", for: .normal)
        $0.setTitleColor(.green, for: .selected)
        $0.setTitleColor(.gray40, for: .normal)
        $0.titleLabel?.font = .medium(size: 14)
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.backgroundView,
            self.indicatorView,
            self.totalButton,
            self.dayButton
        ])
        
        self.totalButton.rx.tap
            .map { FilterType.total }
            .do(onNext: { [weak self] type in
                self?.selectButton(type: type)
            })
            .bind(to: self.tapPublisher)
            .disposed(by: self.disposeBag)
                
        self.dayButton.rx.tap
            .map { FilterType.day }
            .do(onNext: { [weak self] type in
                self?.selectButton(type: type)
            })
            .bind(to: self.tapPublisher)
            .disposed(by: self.disposeBag)
    }
    
    override func bindConstraints() {
        self.backgroundView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(56)
        }
        
        self.totalButton.snp.makeConstraints { make in
            make.left.equalTo(self.backgroundView).offset(8)
            make.top.equalTo(self.backgroundView).offset(8)
            make.bottom.equalTo(self.backgroundView).offset(-8)
            make.right.equalTo(self.snp.centerX).offset(-3)
        }
        
        self.dayButton.snp.makeConstraints { make in
            make.left.equalTo(self.snp.centerX).offset(3)
            make.top.equalTo(self.totalButton)
            make.bottom.equalTo(self.totalButton)
            make.right.equalTo(self.backgroundView).offset(-8)
        }
        
        self.indicatorView.snp.makeConstraints { make in
            make.edges.equalTo(self.totalButton)
        }
        
        self.snp.makeConstraints { make in
            make.edges.equalTo(self.backgroundView).priority(.high)
        }
    }
    
    private func selectButton(type: FilterType) {
        self.totalButton.isSelected = type == .total
        self.dayButton.isSelected = type == .day
        self.indicatorView.snp.remakeConstraints { make in
            make.edges.equalTo(type == .total ? self.totalButton : self.dayButton)
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.layoutIfNeeded()
        }
    }
}

extension Reactive where Base: StatisticsFilterButton {
    var tap: ControlEvent<StatisticsFilterButton.FilterType> {
        return ControlEvent(events: base.tapPublisher)
    }
}
