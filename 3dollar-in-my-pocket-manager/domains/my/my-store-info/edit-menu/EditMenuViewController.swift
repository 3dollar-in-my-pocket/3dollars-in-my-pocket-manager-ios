import UIKit

import ReactorKit

final class EditMenuViewController: BaseViewController, View, EditMenuCoordinator {
    private let editMenuView = EditMenuView()
    private let editMenuReactor: EditMenuReactor
    private weak var coordinator: EditMenuCoordinator?
    
    static func instance(store: Store) -> EditMenuViewController {
        return EditMenuViewController(store: store).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    init(store: Store) {
        self.editMenuReactor = EditMenuReactor(
            store: store,
            storeService: StoreService(),
            imageService: ImageService(),
            globalState: GlobalState.shared
        )
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.editMenuView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.reactor = self.editMenuReactor
    }
    
    override func bindEvent() {
        self.editMenuView.backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.editMenuReactor.dismissPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.presenter.dismiss(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.editMenuReactor.showLoadginPublisher
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.editMenuReactor.showErrorAlert
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.disposeBag)
    }
    
    func bind(reactor: EditMenuReactor) {
        // Bind State
        reactor.state
            .map { $0.store.menus }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(self.editMenuView.menuTableView.rx.items(
                cellIdentifier: EditMenuTableViewCell.registerId,
                cellType: EditMenuTableViewCell.self
            )) { row, menu, cell in
                cell.bind(menu: menu)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isAddMenuButtonHidden }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: true)
            .drive(self.editMenuView.tableViewFooterView.rx.isHidden)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isEnableSaveButton }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(self.editMenuView.saveButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
    }
}
