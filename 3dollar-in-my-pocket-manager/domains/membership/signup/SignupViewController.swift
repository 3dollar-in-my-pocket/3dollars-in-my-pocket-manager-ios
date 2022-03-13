import UIKit

import ReactorKit
import RxSwift

final class SignupViewController: BaseViewController, View {
    private let signupView = SignupView()
    private let signupReactor = SignupReactor(categoryService: CategoryService())
    
    static func instance() -> SignupViewController {
        return SignupViewController(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = self.signupView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reactor = self.signupReactor
        self.signupReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.signupView.backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: self.disposeBag)
    }
    
    func bind(reactor: SignupReactor) {
        // Bind Action
        self.signupView.ownerNameField.rx.text
            .map { Reactor.Action.inputOwnerName($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.signupView.storeNameField.rx.text
            .map { Reactor.Action.inputStoreName($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.signupView.registerationNumberField.rx.text
            .map { Reactor.Action.inputRegisterationNumber($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.signupView.phoneNumberField.rx.text
            .map { Reactor.Action.inputPhoneNumber($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.signupView.categoryCollectionView.categoryCollectionView.rx.itemSelected
            .map { Reactor.Action.selectCategory(index: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.signupView.signupButton.rx.tap
            .map { Reactor.Action.tapSignup }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind state
        reactor.state
            .map { $0.categories }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { [weak self] categories in
                self?.signupView.categoryCollectionView.updateCollectionViewHeight(categories: categories)
            })
            .drive(self.signupView.categoryCollectionView.categoryCollectionView.rx.items(
                cellIdentifier: SignupCategoryCollectionViewCell.registerID,
                cellType: SignupCategoryCollectionViewCell.self
            )) { row, category, cell in
                cell.bind(category: category)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isEnableSignupButton }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(self.signupView.signupButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
    }
}
