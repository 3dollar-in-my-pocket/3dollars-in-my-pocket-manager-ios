import UIKit

final class EditStoreInfoViewController: BaseViewController, EditStoreInfoCoordinator {
    private let editStoreInfoView = EditStoreInfoView()
    private weak var coordinator: EditStoreInfoCoordinator?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    static func instance(store: Store) -> EditStoreInfoViewController {
        return EditStoreInfoViewController(store: store).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    init(store: Store) {
        super.init(nibName: nil, bundle: nil)
        
        self.editStoreInfoView.bind(store: store)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.editStoreInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
    }
    
    override func bindEvent() {
        self.editStoreInfoView.backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
    }
}
