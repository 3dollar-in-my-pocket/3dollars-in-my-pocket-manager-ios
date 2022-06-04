import UIKit
import PhotosUI

import ReactorKit
import Base
import SPPermissions

final class EditMenuViewController: BaseViewController, View, EditMenuCoordinator {
    private let editMenuView = EditMenuView()
    private let editMenuReactor: EditMenuReactor
    private weak var coordinator: EditMenuCoordinator?
    private var selectedCellIndex = 0 // 사진 추가시, 셀 인덱스 확인을 위해 사용
    
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
        // Bind Action
        self.editMenuView.tableViewFooterView.addMenuButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapAddMenuButton }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.editMenuView.saveButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapSaveButton }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
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
                cell.cameraButton.rx.tap
                    .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
                    .asDriver(onErrorJustReturn: ())
                    .do(onNext: { [weak self] in
                        self?.selectedCellIndex = row
                    })
                    .drive(onNext: { [weak self] in
                        self?.coordinator?.showPhotoActionSheet()
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.originalMenuCount }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: 0)
            .drive(self.editMenuView.rx.menuCount)
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

extension EditMenuViewController:
    UIImagePickerControllerDelegate & UINavigationControllerDelegate
{
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            picker.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                
                self.editMenuView.setPhotoInCell(
                    index: self.selectedCellIndex,
                    photo: photo
                )
                self.editMenuReactor.action.onNext(
                    .addPhoto(index: self.selectedCellIndex, photo: photo)
                )
            }
        } else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

extension EditMenuViewController: SPPermissionsDelegate {
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

extension EditMenuViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let photo = image as? UIImage {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        picker.dismiss(animated: true) {
                            self.editMenuView.setPhotoInCell(
                                index: self.selectedCellIndex,
                                photo: photo
                            )
                            self.editMenuReactor.action.onNext(
                                .addPhoto(index: self.selectedCellIndex, photo: photo)
                            )
                        }
                    }
                }
            }
        } else {
            // TODO: Handle empty results or item provider not being able load UIImage
        }
    }
}
