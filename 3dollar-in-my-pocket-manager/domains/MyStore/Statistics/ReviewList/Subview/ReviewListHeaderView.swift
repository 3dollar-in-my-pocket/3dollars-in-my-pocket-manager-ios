import UIKit
import Combine

final class ReviewListHeaderView: UICollectionReusableView {
    enum Layout {
        static let height: CGFloat = 48
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        return stackView
    }()
    
    private let latestOrderButton: FilterButton = {
        let button = FilterButton()
        button.setTitle(Strings.ReviewList.SortType.latest, for: .normal)
        button.titleLabel?.font = .bold(size: 12)
        button.setTitleColor(.gray40, for: .normal)
        button.setTitleColor(.gray100, for: .selected)
        return button
    }()
    
    private let higherRatingOrderButton: FilterButton = {
        let button = FilterButton()
        button.setTitle(Strings.ReviewList.SortType.higherRating, for: .normal)
        button.titleLabel?.font = .bold(size: 12)
        button.setTitleColor(.gray40, for: .normal)
        button.setTitleColor(.gray100, for: .selected)
        return button
    }()
    
    private let lowerRatingOrderButton: FilterButton = {
        let button = FilterButton()
        button.setTitle(Strings.ReviewList.SortType.lowerRating, for: .normal)
        button.titleLabel?.font = .bold(size: 12)
        button.setTitleColor(.gray40, for: .normal)
        button.setTitleColor(.gray100, for: .selected)
        return button
    }()
    
    let didTapSortButton = PassthroughSubject<ReviewSortType, Never>()
    var cancellables = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        addSubview(stackView)
        stackView.addArrangedSubview(latestOrderButton)
        stackView.addArrangedSubview(higherRatingOrderButton)
        stackView.addArrangedSubview(lowerRatingOrderButton)
        
        stackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
        }
    }
    
    private func bind() {
        latestOrderButton.tapPublisher
            .map { ReviewSortType.latest }
            .subscribe(didTapSortButton)
            .store(in: &cancellables)
        
        higherRatingOrderButton.tapPublisher
            .map { ReviewSortType.highestRating }
            .subscribe(didTapSortButton)
            .store(in: &cancellables)
        
        lowerRatingOrderButton.tapPublisher
            .map { ReviewSortType.lowestRating }
            .subscribe(didTapSortButton)
            .store(in: &cancellables)
    }
    
    func bind(sortType: ReviewSortType) {
        latestOrderButton.isSelected = sortType == .latest
        higherRatingOrderButton.isSelected = sortType == .highestRating
        lowerRatingOrderButton.isSelected = sortType == .lowestRating
    }
}

extension ReviewListHeaderView {
    final class FilterButton: UIButton {
        override var isSelected: Bool {
            didSet {
                underLine.isHidden = !isSelected
            }
        }
        
        private let underLine: UIView = {
            let view = UIView()
            view.backgroundColor = .gray100
            view.isHidden = true
            return view
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            addSubview(underLine)
            
            underLine.snp.makeConstraints {
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.height.equalTo(1)
            }
        }
    }
}
