import UIKit
import PhotosUI

import ReactorKit
import RxSwift
import SPPermissions

final class SignupViewController: BaseViewController, View, SignupCoordinator {
    private let signupView = SignupView()
    private let signupReactor: SignupReactor
    private weak var coordinator: SignupCoordinator?
    
    init(socialType: SocialType, token: String) {
        self.signupReactor = SignupReactor(
            socialType: socialType,
            token: token,
            categoryService: CategoryService(),
            imageService: ImageService(),
            authService: AuthService()
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func instance(socialType: SocialType, token: String) -> SignupViewController {
        return SignupViewController(socialType: socialType, token: token)
    }
    
    override func loadView() {
        self.view = self.signupView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reactor = self.signupReactor
        self.coordinator = self
        self.signupReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.signupView.backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: self.disposeBag)
        
        self.signupView.photoView.rx.tapUploadButton
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.showPhotoActionSheet()
            })
            .disposed(by: self.eventDisposeBag)
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
            .map { $0.photo }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
            .drive(self.signupView.photoView.rx.photo)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isEnableSignupButton }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(self.signupView.signupButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
    }
}

extension SignupViewController:
    UIImagePickerControllerDelegate & UINavigationControllerDelegate
{
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.signupReactor.action.onNext(.selectPhoto(photo))
        }
        
        picker.dismiss(animated: true, completion: nil) // picker를 닫아줌
    }
}

extension SignupViewController: SPPermissionsDelegate {
    func didAllowPermission(_ permission: SPPermissions.Permission) {
        if permission == .camera {
            self.coordinator?.showCamera()
        } else if permission == .photoLibrary {
//            self.coordinator?.showRegisterPhoto(storeId: self.viewModel.storeId)
        }
    }
    
    func didDeniedPermission(_ permission: SPPermissions.Permission) {
        let texts = SPPermissionsDeniedAlertTexts()
        
        texts.titleText = "권한 거절"
        texts.descriptionText = "설정에서 해당 권한을 허용해주세요."
        texts.actionText = "설정"
        texts.cancelText = "취소"
    }
}

extension SignupViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider,
            itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let photo = image as? UIImage {
                    self.signupReactor.action.onNext(.selectPhoto(photo))
                }
            }
        } else {
            // TODO: Handle empty results or item provider not being able load UIImage
        }
    }
}
