import UIKit
import PhotosUI

import CombineCocoa
import PermissionsKit

final class CouponRegisterViewController: BaseViewController {
    private let registerView = CouponRegisterView()
    private let viewModel: CouponRegisterViewModel
    
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    init(viewModel: CouponRegisterViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = registerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        viewModel.input.firstLoad.send(())
    }
    
    private func bind() {
        registerView.backButton.tapPublisher
            .main
            .withUnretained(self)
            .sink { (owner: CouponRegisterViewController, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
        
        // Input
        registerView.couponTitleField.textField.textField.textPublisher
            .compactMap { $0 }
            .dropFirst()
            .subscribe(viewModel.input.inputCouponName)
            .store(in: &cancellables)
        
        registerView.dateInputView.startDatePublisher
            .subscribe(viewModel.input.inputStartDate)
            .store(in: &cancellables)
        
        registerView.dateInputView.endDatePublisher
            .subscribe(viewModel.input.inputEndDate)
            .store(in: &cancellables)
        
        registerView.countInputView.updateValue
            .subscribe(viewModel.input.inputCount)
            .store(in: &cancellables)
        
        registerView.registerButton.tapPublisher
            .subscribe(viewModel.input.didTapRegister)
            .store(in: &cancellables)
        
        viewModel.output.isEnableRegisterButton
            .removeDuplicates()
            .main
            .withUnretained(self)
            .sink { (owner: CouponRegisterViewController, isEnable: Bool) in
                owner.registerView.setRegisterButtonEnable(isEnable)
            }
            .store(in: &cancellables)
        
        viewModel.output.toast
            .main
            .sink { message in
                ToastManager.shared.show(message: message)
            }
            .store(in: &cancellables)
        
        viewModel.output.showLoading
            .main
            .sink { (isShow: Bool) in
                LoadingManager.shared.showLoading(isShow: isShow)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: CouponRegisterViewController, route: CouponRegisterViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func handleRoute(_ route: CouponRegisterViewModel.Route) {
        switch route {
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        case .pop:
            navigationController?.popViewController(animated: true)
        case .showRegisterAlertView:
            CouponRegisterAlertViewController.present(from: self, onConfirm: { [weak self] in
                self?.viewModel.input.request.send()
            })
        }
    }
}
