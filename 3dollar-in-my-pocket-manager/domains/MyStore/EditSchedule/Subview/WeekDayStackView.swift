import UIKit
import Combine

final class WeekDayStackView: BaseView {
    enum Layout {
        static let buttonSize = CGSize(width: 38, height: 38)
    }
    
    let tapPublisher = PassthroughSubject<DayOfTheWeek, Never>()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private let mondayButton = WeekDayButton(title: "월")
    private let tuesdayButton = WeekDayButton(title: "화")
    private let wednesdayButton = WeekDayButton(title: "수")
    private let thursdayButton = WeekDayButton(title: "목")
    private let fridayButton = WeekDayButton(title: "금")
    private let saturdayButton = WeekDayButton(title: "토")
    private let sundayButton = WeekDayButton(title: "일")
    
    override func setup() {
        setupLayout()
        setupEvent()
    }
    
    func bind(daysOfTheWeek: [DayOfTheWeek]) {
        mondayButton.isSelected = daysOfTheWeek.contains(.monday)
        tuesdayButton.isSelected = daysOfTheWeek.contains(.tuesday)
        wednesdayButton.isSelected = daysOfTheWeek.contains(.wednesday)
        thursdayButton.isSelected = daysOfTheWeek.contains(.thursday)
        fridayButton.isSelected = daysOfTheWeek.contains(.friday)
        saturdayButton.isSelected = daysOfTheWeek.contains(.saturday)
        sundayButton.isSelected = daysOfTheWeek.contains(.sunday)
    }
    
    private func setupLayout() {
        stackView.addArrangedSubview(mondayButton)
        stackView.addArrangedSubview(tuesdayButton)
        stackView.addArrangedSubview(wednesdayButton)
        stackView.addArrangedSubview(thursdayButton)
        stackView.addArrangedSubview(fridayButton)
        stackView.addArrangedSubview(saturdayButton)
        stackView.addArrangedSubview(sundayButton)
        addSubViews([
            stackView
        ])
        
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(Layout.buttonSize.height)
        }
        
        mondayButton.snp.makeConstraints {
            $0.size.equalTo(Layout.buttonSize)
        }
        
        tuesdayButton.snp.makeConstraints {
            $0.size.equalTo(Layout.buttonSize)
        }
        
        wednesdayButton.snp.makeConstraints {
            $0.size.equalTo(Layout.buttonSize)
        }
        
        thursdayButton.snp.makeConstraints {
            $0.size.equalTo(Layout.buttonSize)
        }
        
        fridayButton.snp.makeConstraints {
            $0.size.equalTo(Layout.buttonSize)
        }
        
        saturdayButton.snp.makeConstraints {
            $0.size.equalTo(Layout.buttonSize)
        }
        
        sundayButton.snp.makeConstraints {
            $0.size.equalTo(Layout.buttonSize)
        }
        
        snp.makeConstraints {
            $0.top.equalTo(stackView).priority(.high)
            $0.bottom.equalTo(stackView).priority(.high)
        }
    }
    
    private func setupEvent() {
        mondayButton.tapPublisher
            .map { DayOfTheWeek.monday }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.mondayButton.isSelected.toggle()
            })
            .subscribe(tapPublisher)
            .store(in: &cancellables)
        
        tuesdayButton.tapPublisher
            .map { DayOfTheWeek.tuesday }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.tuesdayButton.isSelected.toggle()
            })
            .subscribe(tapPublisher)
            .store(in: &cancellables)
        
        wednesdayButton.tapPublisher
            .map { DayOfTheWeek.wednesday }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.wednesdayButton.isSelected.toggle()
            })
            .subscribe(tapPublisher)
            .store(in: &cancellables)
        
        thursdayButton.tapPublisher
            .map { DayOfTheWeek.thursday }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.thursdayButton.isSelected.toggle()
            })
            .subscribe(tapPublisher)
            .store(in: &cancellables)
        
        fridayButton.tapPublisher
            .map { DayOfTheWeek.friday }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.fridayButton.isSelected.toggle()
            })
            .subscribe(tapPublisher)
            .store(in: &cancellables)
        
        saturdayButton.tapPublisher
            .map { DayOfTheWeek.saturday }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.saturdayButton.isSelected.toggle()
            })
            .subscribe(tapPublisher)
            .store(in: &cancellables)
        
        sundayButton.tapPublisher
            .map { DayOfTheWeek.sunday }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.sundayButton.isSelected.toggle()
            })
            .subscribe(tapPublisher)
            .store(in: &cancellables)
    }
}

extension WeekDayStackView {
    private class WeekDayButton: UIButton {
        override var isSelected: Bool {
            didSet {
                layer.borderWidth = isSelected ? 0 : 1
            }
        }
        
        init(title: String) {
            super.init(frame: .zero)
            
            layer.cornerRadius = 19
            layer.borderWidth = 1
            layer.borderColor = UIColor(r: 226, g: 226, b: 226).cgColor
            setBackgroundColor(color: .gray10, forState: .normal)
            setBackgroundColor(color: .black, forState: .selected)
            setTitle(title, for: .normal)
            setTitleColor(.gray40, for: .normal)
            setTitleColor(.white, for: .selected)
            titleLabel?.font = .bold(size: 14)
            adjustsImageWhenHighlighted = false
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
