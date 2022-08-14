import UIKit

import Base
import RxSwift
import RxCocoa

final class WeekDayStackView: BaseView {
    fileprivate let tapPublisher = PublishSubject<DayOfTheWeek>()
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
    }
    
    private let mondayButton = weekDayButton().then {
        $0.setTitle("월", for: .normal)
    }
    
    private let tuesdayButton = weekDayButton().then {
        $0.setTitle("화", for: .normal)
    }
    
    private let wednesdayButton = weekDayButton().then {
        $0.setTitle("수", for: .normal)
    }
    
    private let thursdayButton = weekDayButton().then {
        $0.setTitle("목", for: .normal)
    }
    
    private let fridayButton = weekDayButton().then {
        $0.setTitle("금", for: .normal)
    }
    
    private let saturdayButton = weekDayButton().then {
        $0.setTitle("토", for: .normal)
    }
    
    private let sundayButton = weekDayButton().then {
        $0.setTitle("일", for: .normal)
    }
    
    override func setup() {
        self.stackView.addArrangedSubview(self.mondayButton)
        self.stackView.addArrangedSubview(self.tuesdayButton)
        self.stackView.addArrangedSubview(self.wednesdayButton)
        self.stackView.addArrangedSubview(self.thursdayButton)
        self.stackView.addArrangedSubview(self.fridayButton)
        self.stackView.addArrangedSubview(self.saturdayButton)
        self.stackView.addArrangedSubview(self.sundayButton)
        self.addSubViews([
            self.stackView
        ])
        self.mondayButton.rx.tap
            .map { DayOfTheWeek.monday }
            .do(onNext: { [weak self] _ in
                self?.mondayButton.isSelected.toggle()
            })
            .bind(to: self.tapPublisher)
            .disposed(by: self.disposeBag)
        
        self.tuesdayButton.rx.tap
            .map { DayOfTheWeek.tuesday }
            .do(onNext: { [weak self] _ in
                self?.tuesdayButton.isSelected.toggle()
            })
            .bind(to: self.tapPublisher)
            .disposed(by: self.disposeBag)
        
        self.wednesdayButton.rx.tap
            .map { DayOfTheWeek.wednesday }
            .do(onNext: { [weak self] _ in
                self?.wednesdayButton.isSelected.toggle()
            })
            .bind(to: self.tapPublisher)
            .disposed(by: self.disposeBag)
        
        self.thursdayButton.rx.tap
            .map { DayOfTheWeek.thursday }
            .do(onNext: { [weak self] _ in
                self?.thursdayButton.isSelected.toggle()
            })
            .bind(to: self.tapPublisher)
            .disposed(by: self.disposeBag)
        
        self.fridayButton.rx.tap
            .map { DayOfTheWeek.friday }
            .do(onNext: { [weak self] _ in
                self?.fridayButton.isSelected.toggle()
            })
            .bind(to: self.tapPublisher)
            .disposed(by: self.disposeBag)
        
        self.saturdayButton.rx.tap
            .map { DayOfTheWeek.saturday }
            .do(onNext: { [weak self] _ in
                self?.saturdayButton.isSelected.toggle()
            })
            .bind(to: self.tapPublisher)
            .disposed(by: self.disposeBag)
        
        self.sundayButton.rx.tap
            .map { DayOfTheWeek.sunday }
            .do(onNext: { [weak self] _ in
                self?.sundayButton.isSelected.toggle()
            })
            .bind(to: self.tapPublisher)
            .disposed(by: self.disposeBag)
    }
    
    override func bindConstraints() {
        self.stackView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(38)
        }
        
        self.mondayButton.snp.makeConstraints { make in
            make.width.equalTo(38)
            make.height.equalTo(38)
        }
        
        self.tuesdayButton.snp.makeConstraints { make in
            make.width.equalTo(38)
            make.height.equalTo(38)
        }
        
        self.wednesdayButton.snp.makeConstraints { make in
            make.width.equalTo(38)
            make.height.equalTo(38)
        }
        
        self.thursdayButton.snp.makeConstraints { make in
            make.width.equalTo(38)
            make.height.equalTo(38)
        }
        
        self.fridayButton.snp.makeConstraints { make in
            make.width.equalTo(38)
            make.height.equalTo(38)
        }
        
        self.saturdayButton.snp.makeConstraints { make in
            make.width.equalTo(38)
            make.height.equalTo(38)
        }
        
        self.sundayButton.snp.makeConstraints { make in
            make.width.equalTo(38)
            make.height.equalTo(38)
        }
        
        self.snp.makeConstraints { make in
            make.top.equalTo(self.stackView).priority(.high)
            make.bottom.equalTo(self.stackView).priority(.high)
        }
    }
    
    fileprivate func selectDaysOfTheWeek(daysOfTheWeek: [DayOfTheWeek]) {
        self.mondayButton.isSelected = daysOfTheWeek.contains(.monday)
        self.tuesdayButton.isSelected = daysOfTheWeek.contains(.tuesday)
        self.wednesdayButton.isSelected = daysOfTheWeek.contains(.wednesday)
        self.thursdayButton.isSelected = daysOfTheWeek.contains(.thursday)
        self.fridayButton.isSelected = daysOfTheWeek.contains(.friday)
        self.saturdayButton.isSelected = daysOfTheWeek.contains(.saturday)
        self.sundayButton.isSelected = daysOfTheWeek.contains(.sunday)
    }
    
    private class weekDayButton: UIButton {
        override var isSelected: Bool {
            didSet {
                self.layer.borderWidth = isSelected ? 0 : 1
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.layer.cornerRadius = 19
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor(r: 226, g: 226, b: 226).cgColor
            self.setBackgroundColor(color: .gray10, forState: .normal)
            self.setBackgroundColor(color: .black, forState: .selected)
            self.setTitleColor(.gray40, for: .normal)
            self.setTitleColor(.white, for: .selected)
            self.titleLabel?.font = .bold(size: 14)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension Reactive where Base: WeekDayStackView {
    var tap: ControlEvent<DayOfTheWeek> {
        return ControlEvent(events: base.tapPublisher)
    }
    
    var selectedDay: Binder<[DayOfTheWeek]> {
        return Binder(self.base) { view, daysOfTheWeek in
            view.selectDaysOfTheWeek(daysOfTheWeek: daysOfTheWeek)
        }
    }
}
