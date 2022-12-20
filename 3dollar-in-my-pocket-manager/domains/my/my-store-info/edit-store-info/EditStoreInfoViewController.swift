import UIKit
import PhotosUI

import ReactorKit
import SPPermissions
import CropViewController

final class EditStoreInfoViewController: BaseViewController, View, EditStoreInfoCoordinator {
    private let editStoreInfoView = EditStoreInfoView()
    private let editStoreInfoReactor: EditStoreInfoReactor
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
        self.editStoreInfoReactor = EditStoreInfoReactor(
            store: store,
            storeService: StoreService(),
            categoryService: CategoryService(),
            imageService: ImageService(),
            globalState: GlobalState.shared,
            analyticsManager: AnalyticsManager.shared
        )
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
        self.reactor = self.editStoreInfoReactor
        self.editStoreInfoReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.editStoreInfoView.backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.editStoreInfoView.photoView.rx.tapUploadButton
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.showPhotoActionSheet()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.editStoreInfoReactor.popPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.editStoreInfoReactor.selectCategoriesPublisher
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] indexes in
                self?.editStoreInfoView.selectCategories(indexes: indexes)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.editStoreInfoReactor.showLoadginPublisher
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.editStoreInfoReactor.showErrorAlert
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: EditStoreInfoReactor) {
        // Bind Action
        self.editStoreInfoView.storeNameField.rx.text
            .map { Reactor.Action.inputStoreName($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.editStoreInfoView.categoryCollectionView.categoryCollectionView.rx.itemSelected
            .map { Reactor.Action.selectCategory(index: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.editStoreInfoView.categoryCollectionView.categoryCollectionView.rx.itemDeselected
            .map { Reactor.Action.deselectCategory(index: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.editStoreInfoView.snsField.rx.text
            .map { Reactor.Action.inputSNS($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.editStoreInfoView.saveButton.rx.tap
            .map { Reactor.Action.tapSave }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { $0.categories }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { [weak self] categories in
                self?.editStoreInfoView.categoryCollectionView.updateCollectionViewHeight(
                    categories: categories
                )
            })
            .drive(self.editStoreInfoView.categoryCollectionView.categoryCollectionView.rx.items(
                cellIdentifier: SignupCategoryCollectionViewCell.registerID,
                cellType: SignupCategoryCollectionViewCell.self
            )) { row, category, cell in
                cell.bind(category: category)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isEnableSaveButton }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(self.editStoreInfoView.saveButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .compactMap { $0.photo }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
            .drive(self.editStoreInfoView.photoView.rx.photo)
            .disposed(by: self.disposeBag)
    }
}

extension EditStoreInfoViewController:
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

extension EditStoreInfoViewController: SPPermissionsDelegate {
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

extension EditStoreInfoViewController: PHPickerViewControllerDelegate {
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

extension EditStoreInfoViewController: CropViewControllerDelegate {
    func cropViewController(
        _ cropViewController: CropViewController,
        didCropToImage image: UIImage,
        withRect cropRect: CGRect,
        angle: Int
    ) {
        cropViewController.dismiss(animated: true, completion: nil)
        self.editStoreInfoReactor.action.onNext(.selectPhoto(image))
    }
}
