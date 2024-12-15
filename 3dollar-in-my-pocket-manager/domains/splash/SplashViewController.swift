import UIKit

import Lottie

final class SplashViewController: BaseViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let animationView: LottieAnimationView = {
        let animationView = LottieAnimationView(name: "splash")
        animationView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        animationView.contentMode = .scaleAspectFit
        return animationView
    }()
    
    private let viewModel: SplashViewModel
    
    init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNotification()
        bind()
    }
    
    private func setupUI() {
        view.backgroundColor = .gray100
        view.addSubview(animationView)
        
        animationView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(UIUtils.windowBounds.width)
            $0.height.equalTo(UIUtils.windowBounds.width)
        }
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func willEnterForeground() {
        viewModel.input.load.send(())
        startAnimation()
    }
    
    private func startAnimation() {
        animationView.play { [weak self] _ in
            self?.viewModel.input.finishAnimation.send(())
        }
    }
    
    private func bind() {
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: SplashViewController, error: any Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: SplashViewController, route: SplashViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    func bind(reactor: SplashReactor) { }
}

// MARK: Route
extension SplashViewController {
    private func handleRoute(_ route: SplashViewModel.Route) {
        switch route {
        case .goToSignIn:
            goToSignIn()
        case .goToMain:
            goToMain()
        case .goToWaiting:
            goToWaiting()
        }
    }
    
    private func goToSignIn() {
        guard let sceneDelegate = UIApplication
            .shared
            .connectedScenes
            .first?.delegate as? SceneDelegate else {
            return
        }
        
        sceneDelegate.goToSignin()
    }
    
    private func goToMain() {
        guard let sceneDelegate = UIApplication
            .shared
            .connectedScenes
            .first?.delegate as? SceneDelegate else {
            return
        }
        
        sceneDelegate.goToMain()
    }
    
    private func goToWaiting() {
        guard let sceneDelegate = UIApplication
            .shared
            .connectedScenes
            .first?.delegate as? SceneDelegate else {
            return
        }
        
        sceneDelegate.goToWaiting()
    }
}
