import UIKit

final class EditIntroductionViewController: BaseViewController {
    private let viewModel: EditIntroductionViewModel
    private let editIntroductionView = EditIntroductionView()
    
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    init(viewModel: EditIntroductionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = editIntroductionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    private func bind() {
        // Event
        editIntroductionView.backButton.tapPublisher
            .main
            .withUnretained(self)
            .sink { (owner: EditIntroductionViewController, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
        
        // Input
        editIntroductionView.textView.textPublisher
            .subscribe(viewModel.input.inputText)
            .store(in: &cancellables)
        
        editIntroductionView.editButton.tapPublisher
            .subscribe(viewModel.input.didTapEdit)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.store
            .main
            .withUnretained(self)
            .sink { (owner: EditIntroductionViewController, store: BossStoreResponse) in
                owner.editIntroductionView.bind(introduction: store.introduction)
            }
            .store(in: &cancellables)
        
        viewModel.output.isEditButtonEnable
            .main
            .withUnretained(self)
            .sink { (owner: EditIntroductionViewController, isEnable: Bool) in
                owner.editIntroductionView.setEditButtonEnable(isEnable)
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
            .sink { (owner: EditIntroductionViewController, route: EditIntroductionViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func handleRoute(_ route: EditIntroductionViewModel.Route) {
        switch route {
        case .pop:
            navigationController?.popViewController(animated: true)
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
}
