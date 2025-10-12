import UIKit
import Combine
import CombineCocoa

enum MyPageSubTabType: CaseIterable {
    case info
    case statistics
    case notice
    case message
    case coupon
    
    var tabName: String {
        switch self {
        case .info:
            return "myStoreInfo"
        case .statistics:
            return "statistics"
        case .notice:
            return "storePost"
        case .message:
            return "message"
        case .coupon:
            return "coupon"
        }
    }
}

final class MyPageSubTabView: BaseView {
    let didTapPublisher = PassthroughSubject<MyPageSubTabType, Never>()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .bottom
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        return stackView
    }()
    
    let infoButton = MyPageSubTab(title: Strings.MyPage.SubTab.storeInfo, isSelected: true)
    
    let statisticsButton = MyPageSubTab(title: Strings.MyPage.SubTab.statistics, isSelected: false)
    
    let storeNoticeButton = MyPageSubTab(title: Strings.MyPage.SubTab.notice, isSelected: false)
    
    let messageButton = MyPageSubTab(title: Strings.MyPage.SubTab.message, isSelected: false)
    
    let couponButton = MyPageSubTab(title: Strings.MyPage.SubTab.coupon, isSelected: false)
    
    override func setup() {
        setupUI()
        bind()
    }
    
    private func setupUI() {
        stackView.addArrangedSubview(infoButton)
        stackView.addArrangedSubview(statisticsButton)
        stackView.addArrangedSubview(storeNoticeButton)
        stackView.addArrangedSubview(messageButton)
        stackView.addArrangedSubview(couponButton)
        scrollView.addSubview(stackView)
        addSubview(scrollView)
        
        scrollView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(35)
        }
        
        snp.makeConstraints {
            $0.height.equalTo(51)
        }
    }
    
    private func bind() {
        let didTapInfo = infoButton.tapPublisher
            .map { MyPageSubTabType.info }
        let didTapStatistics = statisticsButton.tapPublisher
            .map { MyPageSubTabType.statistics }
        let didTapStoreNotice = storeNoticeButton.tapPublisher
            .map { MyPageSubTabType.notice }
        let didTapMessage = messageButton.tapPublisher
            .map { MyPageSubTabType.message }
        let didTapCoupon = couponButton.tapPublisher
            .map { MyPageSubTabType.coupon }
        
        Publishers.Merge4(didTapInfo, didTapStatistics, didTapStoreNotice, didTapMessage.merge(with: didTapCoupon))
            .subscribe(didTapPublisher)
            .store(in: &cancellables)
    }
    
    func selectButton(_ tabType: MyPageSubTabType) {
        infoButton.isSelected = tabType == .info
        statisticsButton.isSelected = tabType == .statistics
        storeNoticeButton.isSelected = tabType == .notice
        messageButton.isSelected = tabType == .message
        couponButton.isSelected = tabType == .coupon
    }
}
