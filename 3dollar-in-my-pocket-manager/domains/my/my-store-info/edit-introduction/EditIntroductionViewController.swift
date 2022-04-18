import UIKit

final class EditIntroductionViewController: BaseViewController {
    private let editIntroductionView = EditIntroductionView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    static func instance() -> EditIntroductionViewController {
        return EditIntroductionViewController(nibName: nil, bundle: nil).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    override func loadView() {
        self.view = self.editIntroductionView
    }
    
    override func bindEvent() {
        self.editIntroductionView.backButton.rx.tap
            .asDriver()
            .drive(onNext: {[weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
    }
}
