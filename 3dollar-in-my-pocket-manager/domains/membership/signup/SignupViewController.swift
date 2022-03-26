import UIKit
import PhotosUI

import ReactorKit
import RxSwift
import SPPermissions
import Base
import CropViewController

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
            authService: AuthService(),
            userDefaultsUtils: UserDefaultsUtils()
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
        
        self.signupReactor.pushWaitingPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.goToWaiting()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.signupReactor.goToSigninPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.presenter.navigationController?.popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.signupReactor.showLoadginPublisher
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.signupReactor.showErrorAlert
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
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
            picker.dismiss(animated: true) { [weak self] in
                self?.coordinator?.presentPhotoCrop(photo: photo)
            }
        } else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

extension SignupViewController: SPPermissionsDelegate {
    func didAllowPermission(_ permission: SPPermissions.Permission) {
        if permission == .camera {
            self.coordinator?.showCamera()
        } else if permission == .photoLibrary {
            self.coordinator?.showAlbumPicker()
        }
    }
    
    func didDeniedPermission(_ permission: SPPermissions.Permission) {
        AlertUtils.showWithCancel(
            viewController: self,
            title: "authorization_denied_title".localized,
            message: "authorization_denied_description".localized,
            okButtonTitle: "authorization_setting".localized
        ) {
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}

extension SignupViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let photo = image as? UIImage {
                    DispatchQueue.main.async { [weak self] in
                        picker.dismiss(animated: true) {
                            self?.coordinator?.presentPhotoCrop(photo: photo)
                        }
                    }
                }
            }
        } else {
            // TODO: Handle empty results or item provider not being able load UIImage
        }
    }
}

extension SignupViewController: CropViewControllerDelegate {
    func cropViewController(
        _ cropViewController: CropViewController,
        didCropToImage image: UIImage,
        withRect cropRect: CGRect,
        angle: Int
    ) {
        cropViewController.dismiss(animated: true, completion: nil)
        self.signupReactor.action.onNext(.selectPhoto(image))
    }
}
