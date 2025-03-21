import UIKit
import Combine

import RxSwift

class BaseViewController: UIViewController {
    var disposeBag = DisposeBag()
    var eventDisposeBag = DisposeBag()
    var cancellables = Set<AnyCancellable>()
    var screenName: ScreenName {
        return .empty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sendPageView()
    }
    
    /// Reactor를 거치지 않고 바로 바인딩 되는 단순 이벤트를 정의합니다.
    func bindEvent() { }
    
    func showErrorAlert(error: Error) {
        if let httpError = error as? HTTPError {
            switch httpError {
            case .unauthorized:
                AlertUtils.showWithAction(
                    viewController: self,
                    title: nil,
                    message: httpError.description,
                    okbuttonTitle: "common_ok".localized
                ) {
                    Preference.shared.clear()
                    self.goToSignin()
                }
            case .maintenance:
                showMaintenanceAlert(message: nil)
            default:
                break
            }
        } else if let apiError = error as? ApiError {
            handleApiError(apiError)
        } else if let localizedError = error as? LocalizedError {
            AlertUtils.showWithAction(
                viewController: self,
                message: localizedError.errorDescription,
                onTapOk: nil
            )
        } else {
            AlertUtils.showWithAction(
                viewController: self,
                message: error.localizedDescription,
                onTapOk: nil
            )
        }
    }
    
    func addNavigationBar() {
        guard let navigationController = navigationController else { return }
        
        navigationController.isNavigationBarHidden = false
        navigationController.navigationBar.shadowImage = UIImage() // 스크롤 시 나타나는 그림자 제거
        navigationController.navigationBar.barTintColor = .white
        navigationController.navigationBar.tintColor = .gray100
        addBackButtonIfNeeded()
        setupTitle()
    }
    
    private func addBackButtonIfNeeded() {
        guard navigationController?.viewControllers.count != 0 else { return }
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.image = Assets.icBack.image.withRenderingMode(.alwaysTemplate)
        let backButton = UIButton(configuration: buttonConfig)
        backButton.tintColor = .gray100
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func setupTitle() {
        guard let navigationController = navigationController else { return }
        
        navigationController.navigationBar.titleTextAttributes = [
            .font: UIFont.bold(size: 16) as Any,
            .foregroundColor: UIColor.gray100
        ]
    }
    
    private func goToSignin() {
        guard let sceneDelegate = UIApplication
            .shared
            .connectedScenes
            .first?.delegate as? SceneDelegate else {
            return
        }
        
        sceneDelegate.goToSignin()
    }
    
    private func handleApiError(_ error: ApiError) {
        var message: String
        switch error {
        case .decodingError:
            message = "error.unknown".localized
        case .serverError(let errorMessage):
            message = errorMessage
        case .emptyData:
            message = "error.unknown".localized
        case .errorContainer(let container):
            handleErrorContainer(container)
            return
        }
        AlertUtils.showWithAction(
            viewController: self,
            message: message,
            onTapOk: nil
        )
    }
    
    private func sendPageView() {
        if screenName != .empty {
            LogManager.shared.sendPageView(screen: screenName, type: Self.self)
        }
    }
    
    private func handleErrorContainer(_ container: ApiErrorContainer) {
        switch container.error {
        case .unauthorized:
            showUnauthorizedAlert(message: container.message)
        case .serviceUnavailable:
            showMaintenanceAlert(message: container.message)
        default:
            showDefaultAlert(container: container)
        }
    }
    
    private func showUnauthorizedAlert(message: String?) {
        AlertUtils.showWithAction(
            viewController: self,
            title: nil,
            message: message ?? "",
            okbuttonTitle: Strings.commonOk
        ) {
            Preference.shared.clear()
            self.goToSignin()
        }
    }
    
    private func showMaintenanceAlert(message: String?) {
        guard let topViewController = UIUtils.topViewController() else { return }
        AlertUtils.showWithAction(viewController: topViewController, title: nil, message: message ?? HTTPError.maintenance.description) {
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        }
    }
    
    private func showDefaultAlert(container: ApiErrorContainer) {
        AlertUtils.showWithAction(viewController: self, message: container.message, onTapOk: nil)
    }
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
}

