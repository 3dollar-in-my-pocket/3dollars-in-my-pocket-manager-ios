import UIKit
import CombineCocoa

final class CouponTabViewController: BaseViewController {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .gray0
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    private let tabButton = CouponTabButton()
    
    private let containerView = UIView()
    
    private let couponRegisterButton: UIButton = {
        let button = UIButton()
        button.setTitle("쿠폰 만들기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .medium(size: 14)
        button.backgroundColor = .green
        button.setImage(Assets.couponSolid.image, for: .normal)
        button.layer.cornerRadius = 22
        button.layer.shadowColor = UIColor.green.cgColor
        button.layer.shadowOpacity = 0.4
        button.adjustsImageWhenHighlighted = false
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.masksToBounds = true
        button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 4)
        return button
    }()
    
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil
    )
    private var pageViewControllers: [UIViewController] = []
    
    private let viewModel: CouponTabViewModel
    private var activeCouponViewController: CouponViewController?
    private var nonActiveCouponViewController: CouponViewController?
    
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    init(viewModel: CouponTabViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        
        viewModel.input.viewDidLoad.send(())
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(r: 251, g: 251, b: 251)

        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(tabButton)
        
        stackView.addArrangedSubview(containerView)
        containerView.snp.makeConstraints {
            $0.height.equalTo(UIUtils.windowBounds.height - 200)
        }
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.width.equalTo(UIUtils.windowBounds.width)
        }
        
        view.addSubview(couponRegisterButton)
        couponRegisterButton.snp.makeConstraints {
            $0.height.equalTo(44)
            $0.width.equalTo(118)
            $0.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
    }
    
    private func bind() {
        tabButton.tapPublisher
            .removeDuplicates()
            .subscribe(viewModel.input.didTapTabButton)
            .store(in: &cancellables)
        
        couponRegisterButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapRegisterButton)
            .store(in: &cancellables)
        
        viewModel.output.setPageViewController
            .main
            .withUnretained(self)
            .sink { (owner: CouponTabViewController, viewModels) in
                let (activeCouponViewModel, nonActiveCouponViewModel) = viewModels
                let selectedTab = owner.viewModel.output.tab.value
                owner.setupPageViewController(activeCouponViewModel: activeCouponViewModel, nonActiveCouponViewModel: nonActiveCouponViewModel, selectedTab: selectedTab)
            }
            .store(in: &cancellables)
        
        viewModel.output.tab
            .dropFirst()
            .main
            .withUnretained(self)
            .sink { (owner: CouponTabViewController, filterType: CouponTabButton.CouponTabType) in
                owner.setPage(filterType: filterType)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: CouponTabViewController, route: CouponTabViewModel.Route) in
                switch route {
                case .pushCouponRegister(let viewModel):
                    owner.navigationController?.pushViewController(CouponRegisterViewController(viewModel: viewModel), animated: true)
                case .showErrorAlert:
                    break
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.isEnabledRegisterButton
            .main
            .withUnretained(self)
            .sink { (owner: CouponTabViewController, isEnabled: Bool) in
                owner.couponRegisterButton.isEnabled = isEnabled
                owner.couponRegisterButton.backgroundColor = isEnabled ? .green : .gray40
            }
            .store(in: &cancellables)
    }
    
    private func setupPageViewController(
        activeCouponViewModel: CouponViewModel,
        nonActiveCouponViewModel: CouponViewModel,
        selectedTab: CouponTabButton.CouponTabType
    ) {
        let activeCouponViewController = CouponViewController(viewModel: activeCouponViewModel)
        self.activeCouponViewController = activeCouponViewController
        
        let nonActiveCouponViewController = CouponViewController(viewModel: nonActiveCouponViewModel)
        self.nonActiveCouponViewController = nonActiveCouponViewController
        
        pageViewControllers.removeAll()
        pageViewControllers = [
            activeCouponViewController,
            nonActiveCouponViewController
        ]
        if pageViewController.parent.isNil {
            addChild(pageViewController)
            containerView.addSubview(pageViewController.view)
            pageViewController.view.snp.makeConstraints {
                $0.edges.equalTo(containerView)
            }
        }
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        var selectedViewController: UIViewController
        switch selectedTab {
        case .active:
            selectedViewController = activeCouponViewController
        case .nonActive:
            selectedViewController = nonActiveCouponViewController
        }
        
        pageViewController.setViewControllers(
            [selectedViewController],
            direction: .forward,
            animated: false,
            completion: nil
        )
    }
    
    private func setPage(filterType: CouponTabButton.CouponTabType) {
        switch filterType {
        case .active:
            pageViewController.setViewControllers(
                [pageViewControllers[0]],
                direction: .forward,
                animated: false,
                completion: nil
            )
            
        case .nonActive:
            pageViewController.setViewControllers(
                [pageViewControllers[1]],
                direction: .forward,
                animated: false,
                completion: nil
            )
        }
    }
}

extension CouponTabViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        return nil
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        return nil
    }
}
