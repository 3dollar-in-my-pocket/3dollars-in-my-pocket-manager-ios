import UIKit

import ReactorKit

protocol EditIntroductionDelegate: AnyObject {
    func onUpdateIntroduction(introduction: String)
}

final class EditIntroductionViewController:
    BaseViewController, View, EditIntroductionCoordinator {
    weak var delegate: EditIntroductionDelegate?
    private let editIntroductionView = EditIntroductionView()
    private let editIntroductionReactor: EditIntroductionReactor
    private weak var coordinator: EditIntroductionCoordinator?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    static func instance(
        storeId: String,
        introduction: String?
    ) -> EditIntroductionViewController {
        return EditIntroductionViewController(
            storeId: storeId,
            introduction: introduction
        ).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    init(storeId: String, introduction: String?) {
        self.editIntroductionReactor = EditIntroductionReactor(
            storeId: storeId,
            storeService: StoreService(),
            introduction: introduction
        )
        
        super.init(nibName: nil, bundle: nil)
        self.editIntroductionView.bind(introduction: introduction)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.editIntroductionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.reactor = self.editIntroductionReactor
    }
    
    override func bindEvent() {
        self.editIntroductionView.rx.tapBackground
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.editIntroductionView.endEditing(true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.editIntroductionView.backButton.rx.tap
            .asDriver()
            .drive(onNext: {[weak self] in
                self?.coordinator?.popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.editIntroductionReactor.popupWithIntroductionPublisher
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] introduction in
                self?.delegate?.onUpdateIntroduction(introduction: introduction)
                self?.coordinator?.popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.editIntroductionReactor.showLoadginPublisher
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.editIntroductionReactor.showErrorAlert
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: EditIntroductionReactor) {
        // Bind action
        self.editIntroductionView.textView.rx.text
            .map { Reactor.Action.inputText($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.editIntroductionView.editButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapEditButton }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind state
        self.editIntroductionReactor.state
            .map { $0.isEditButtonEnable }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(self.editIntroductionView.editButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
    }
}
