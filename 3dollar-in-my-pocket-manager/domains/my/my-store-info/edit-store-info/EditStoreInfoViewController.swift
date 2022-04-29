import UIKit

final class EditStoreInfoViewController: BaseViewController, EditStoreInfoCoordinator {
    private let editStoreInfoView = EditStoreInfoView()
    private weak var coordinator: EditStoreInfoCoordinator?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    static func instance() -> EditStoreInfoViewController {
        return EditStoreInfoViewController(nibName: nil, bundle: nil).then {
            $0.hidesBottomBarWhenPushed = true
        }
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
