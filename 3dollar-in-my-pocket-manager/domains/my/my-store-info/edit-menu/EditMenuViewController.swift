import UIKit

final class EditMenuViewController: BaseViewController, EditMenuCoordinator {
    private let editMenuView = EditMenuView()
    private weak var coordinator: EditMenuCoordinator?
    
    static func instance() -> EditMenuViewController {
        return EditMenuViewController(nibName: nil, bundle: nil).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    override func loadView() {
        self.view = self.editMenuView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
    }
    
    override func bindEvent() {
        self.editMenuView.backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
    }
}
